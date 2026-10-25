USE zuri_logistics;

INSERT INTO customers (company_name, first_name, email, phone, customer_type, city, province)
SELECT 'Zuri Logistics Group PTY LTD', 'Zuri', 'sales@zurilogisticsgroup.co.za', '063 836 6355', 'business', 'Johannesburg', 'Gauteng'
WHERE NOT EXISTS (
  SELECT 1 FROM customers WHERE email = 'sales@zurilogisticsgroup.co.za'
);
