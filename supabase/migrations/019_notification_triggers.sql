-- =====================================================
-- 019_notification_triggers.sql
-- Auto-create notifications on key events
-- =====================================================

-- Function: notify on order status change
CREATE OR REPLACE FUNCTION fn_notify_order_status()
RETURNS TRIGGER AS $$
DECLARE
  _title TEXT;
  _body  TEXT;
BEGIN
  -- Only fire on actual status changes
  IF OLD.status = NEW.status THEN
    RETURN NEW;
  END IF;

  _title := CASE NEW.status
    WHEN 'confirmed'  THEN 'تم تأكيد طلبك'
    WHEN 'preparing'  THEN 'طلبك قيد التجهيز'
    WHEN 'ready'      THEN 'طلبك جاهز للإستلام'
    WHEN 'picked_up'  THEN 'السائق استلم طلبك'
    WHEN 'delivered'  THEN 'تم توصيل طلبك'
    WHEN 'completed'  THEN 'تم إكمال طلبك بنجاح ✅'
    WHEN 'cancelled'  THEN 'تم إلغاء طلبك'
    ELSE 'تحديث حالة الطلب'
  END;

  _body := 'طلب #' || LEFT(NEW.id::text, 8) || ' - ' || _title;

  INSERT INTO notifications (user_id, title_ar, body_ar, type, data)
  VALUES (
    NEW.consumer_id,
    _title,
    _body,
    'order_status',
    jsonb_build_object('order_id', NEW.id, 'status', NEW.status)
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_notify_order_status ON orders;
CREATE TRIGGER trg_notify_order_status
  AFTER UPDATE OF status ON orders
  FOR EACH ROW
  EXECUTE FUNCTION fn_notify_order_status();


-- Function: notify on new chat message
CREATE OR REPLACE FUNCTION fn_notify_new_message()
RETURNS TRIGGER AS $$
DECLARE
  _other_uid UUID;
  _room      RECORD;
BEGIN
  -- Get the room to find the other participant
  SELECT * INTO _room FROM chat_rooms WHERE id = NEW.room_id;
  IF _room IS NULL THEN RETURN NEW; END IF;

  -- Determine the recipient (the other user in the room)
  IF NEW.sender_id = _room.user_a THEN
    _other_uid := _room.user_b;
  ELSE
    _other_uid := _room.user_a;
  END IF;

  INSERT INTO notifications (user_id, title_ar, body_ar, type, data)
  VALUES (
    _other_uid,
    'رسالة جديدة 💬',
    LEFT(NEW.content, 80),
    'chat_message',
    jsonb_build_object('room_id', NEW.room_id, 'message_id', NEW.id)
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_notify_new_message ON chat_messages;
CREATE TRIGGER trg_notify_new_message
  AFTER INSERT ON chat_messages
  FOR EACH ROW
  EXECUTE FUNCTION fn_notify_new_message();


-- Function: notify on new diagnosis report
CREATE OR REPLACE FUNCTION fn_notify_new_diagnosis()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notifications (user_id, title_ar, body_ar, type, data)
  VALUES (
    NEW.consumer_id,
    'تقرير فحص جديد 🔍',
    'تم إنشاء تقرير فحص جديد لسيارتك من الورشة',
    'diagnosis_report',
    jsonb_build_object('report_id', NEW.id, 'workshop_id', NEW.workshop_id)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_notify_new_diagnosis ON diagnosis_reports;
CREATE TRIGGER trg_notify_new_diagnosis
  AFTER INSERT ON diagnosis_reports
  FOR EACH ROW
  EXECUTE FUNCTION fn_notify_new_diagnosis();


-- Function: notify on new workshop bill
CREATE OR REPLACE FUNCTION fn_notify_new_bill()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notifications (user_id, title_ar, body_ar, type, data)
  VALUES (
    NEW.consumer_id,
    'فاتورة جديدة من الورشة 🧾',
    'لديك فاتورة بمبلغ ' || NEW.labor_amount || ' ر.ق بانتظار الموافقة',
    'workshop_bill',
    jsonb_build_object('bill_id', NEW.id, 'order_id', NEW.order_id)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_notify_new_bill ON workshop_bills;
CREATE TRIGGER trg_notify_new_bill
  AFTER INSERT ON workshop_bills
  FOR EACH ROW
  EXECUTE FUNCTION fn_notify_new_bill();


-- Enable Realtime on notifications table
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- Enable Realtime on orders table (for live order tracking)
ALTER PUBLICATION supabase_realtime ADD TABLE orders;
