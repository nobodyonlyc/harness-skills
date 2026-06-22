# Common Issues — Bad vs Good

## N+1 query
```python
# BAD
for u in users: orders = Order.objects.filter(user=u)
# GOOD
users = User.objects.prefetch_related("orders").all()
```

## Magic number / status code
```python
# BAD
if status == 3: ...
# GOOD
if status == OrderStatus.SHIPPED: ...
```

## Swallowed error
```python
# BAD
try: risky()
except Exception: pass
# GOOD
try: risky()
except SpecificError as e: log.error("risky failed", exc_info=e); raise
```

## Injection
```python
# BAD
cur.execute(f"SELECT * FROM users WHERE id = {uid}")
# GOOD
cur.execute("SELECT * FROM users WHERE id = %s", (uid,))
```

## Unbounded growth / no pagination
```python
# BAD
return db.query(Order).all()          # loads everything
# GOOD
return db.query(Order).limit(page_size).offset(...).all()
```

## Mutable default argument
```python
# BAD
def add(item, bucket=[]): bucket.append(item); return bucket
# GOOD
def add(item, bucket=None): bucket = bucket or []; ...
```
