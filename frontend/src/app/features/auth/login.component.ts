import { Component,inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import {
  ArrowRight,
  Eye,
  Info,
  Lock,
  LucideAngularModule,
  ShieldAlert,
  Sparkles,
  User
} from 'lucide-angular';
import { AuthService } from '../../core/services/auth.service';
import { LoginRequest } from '../../core/models/api.model';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, LucideAngularModule],
  templateUrl: './login.component.html'
})
export class LoginComponent {

  
  private readonly fb = inject(FormBuilder);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  readonly Sparkles = Sparkles;
  readonly User = User;
  readonly Lock = Lock;
  readonly Eye = Eye;
  readonly Info = Info;
  readonly ArrowRight = ArrowRight;
  readonly ShieldAlert = ShieldAlert;

  cargando = signal(false);
  mensajeError = signal('');

  loginForm = this.fb.group({
    dni: ['', [Validators.required]],
    password: ['', [Validators.required]]
  });


  iniciarSesion(): void {
    if (this.loginForm.invalid) {
      this.mensajeError.set('Ingrese DNI y contraseña.');
      this.loginForm.markAllAsTouched();
      return;
    }

    this.cargando.set(true);
    this.mensajeError.set('');

    const request = this.loginForm.getRawValue() as LoginRequest;

    this.authService.login(request).subscribe({
      next: (response) => {
        this.authService.guardarSesion(response);

        const rol = response.rol.toUpperCase();

        if (rol === 'PACIENTE') {
          this.router.navigate(['/portal/citas']);
          return;
        }

        if (rol === 'ADMINISTRADOR' || rol === 'ODONTOLOGO') {
          this.router.navigate(['/admin/dashboard']);
          return;
        }

        this.mensajeError.set('Rol no autorizado.');
        this.cargando.set(false);
        this.router.navigate(['/login']);
      },
      error: () => {
        this.mensajeError.set('Credenciales inválidas o error del servidor.');
        this.cargando.set(false);
      }
    });
  }
}
