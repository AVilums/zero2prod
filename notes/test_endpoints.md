### Health check
```powershell
Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -Method GET
```

### Subscribe (valid form body)
```powershell
Invoke-WebRequest -Uri "http://127.0.0.1:8000/subscribe" -Method POST -ContentType "application/x-www-form-urlencoded" -Body "name=le%20guin&email=ursula_le_guin%40gmail.com"
```

### Negative test
```powershell
Invoke-WebRequest "http://127.0.0.1:8000/subscribe" -Method POST -ContentType "application/x-www-form-urlencoded" -Body "name=onlyname" -ErrorAction Stop
```