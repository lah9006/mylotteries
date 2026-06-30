from django.shortcuts import render
from .models import Sorteo

def home(request):
    sorteos = Sorteo.objects.filter(activo=True).order_by('-fecha_sorteo')
    return render(request, 'core/home.html', {'sorteos': sorteos})

from django.contrib.auth.forms import UserCreationForm
from django.urls import reverse_lazy
from django.views.generic import CreateView

class RegistroUsuario(CreateView):
    form_class = UserCreationForm
    template_name = 'core/registro.html'
    success_url = reverse_lazy('login')
