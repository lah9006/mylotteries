from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone

class Sorteo(models.Model):
    nombre = models.CharField(max_length=200)
    fecha_sorteo = models.DateTimeField()
    numeros_ganadores = models.JSONField(default=list, blank=True)
    creado_por = models.ForeignKey(User, on_delete=models.CASCADE)
    activo = models.BooleanField(default=True)

    def __str__(self):
        return self.nombre

class LicenciaPremium(models.Model):
    usuario = models.OneToOneField(User, on_delete=models.CASCADE, related_name='licencia')
    es_premium = models.BooleanField(default=False)
    fecha_expiracion = models.DateTimeField(null=True, blank=True)

    def esta_activa(self):
        if not self.es_premium:
            return False
        if self.fecha_expiracion and self.fecha_expiracion < timezone.now():
            return False
        return True

    def __str__(self):
        return f"{self.usuario.username} - Premium: {self.es_premium}"