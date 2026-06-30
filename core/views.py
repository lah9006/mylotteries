import logging
from django.shortcuts import render
from django.contrib.auth.forms import UserCreationForm
from django.urls import reverse_lazy
from django.views.generic import CreateView
from .models import Sorteo

logger = logging.getLogger(__name__)

def home(request):
    try:
        sorteos = Sorteo.objects.filter(activo=True).order_by('-fecha_sorteo')
        return render(request, 'core/home.html', {'sorteos': sorteos})
    except Exception as e:
        logger.error(f'Error en home: {e}', exc_info=True)
        raise

class RegistroUsuario(CreateView):
    form_class = UserCreationForm
    template_name = 'core/registro.html'
    success_url = reverse_lazy('login')
