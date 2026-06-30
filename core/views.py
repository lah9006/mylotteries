from django.shortcuts import render
from django.contrib.auth.forms import UserCreationForm
from django.urls import reverse_lazy
from django.views.generic import CreateView
from .models import Sorteo

def home(request):
    try:
        sorteos = Sorteo.objects.filter(activo=True).order_by('-fecha_sorteo')
        return render(request, 'core/home.html', {'sorteos': sorteos})
    except Exception as e:
        # Esto mostrar? el error en los logs de Render
        import logging
        logging.error(f"Error en home: {e}")
        raise
