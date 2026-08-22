import { Injectable, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environments';
import { LoginRequest, LoginResponse } from '../models/api.model';
import { RegistroPacienteRequest, RegistroPacienteResponse } from '../models/api.model';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly apiUrl = `${environment.apiBaseUrl}/auth`;

  readonly token = signal<string | null>(this.getToken());
  readonly rol = signal<string | null>(this.getRol());

  constructor(private readonly http: HttpClient) {}

  login(request: LoginRequest): Observable<LoginResponse> {
    return this.http.post<LoginResponse>(`${this.apiUrl}/login`, request);
  }

  guardarSesion(response: LoginResponse): void {
    localStorage.setItem('token', response.accessToken);
    localStorage.setItem('rol', response.rol.toUpperCase());

    this.token.set(response.accessToken);
    this.rol.set(response.rol.toUpperCase());
  }

  cerrarSesion(): void {
    localStorage.removeItem('token');
    localStorage.removeItem('rol');

    this.token.set(null);
    this.rol.set(null);
  }

  getToken(): string | null {
    return localStorage.getItem('token');
  }

  getRol(): string | null {
    return localStorage.getItem('rol');
  }

  estaAutenticado(): boolean {
    return !!this.getToken();
  }

    registrarPaciente(request: RegistroPacienteRequest): Observable<RegistroPacienteResponse> {
      return this.http.post<RegistroPacienteResponse>(`${this.apiUrl}/registro/paciente`, request);
    }

    logoutBackend(): Observable<string> {
        return this.http.post(`${this.apiUrl}/logout`, {}, {
            responseType: 'text'
        });
        }
}
