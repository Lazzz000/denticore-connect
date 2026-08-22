package com.cibertec.denticore.security.controllers;

import com.cibertec.denticore.security.dto.request.LoginRequestDTO;
import com.cibertec.denticore.security.dto.request.RegistroPacienteRequestDTO;
import com.cibertec.denticore.security.dto.response.LoginResponseDTO;
import com.cibertec.denticore.security.dto.response.RegistroPacienteResponseDTO;
import com.cibertec.denticore.security.config.CustomUserDetails;
import com.cibertec.denticore.security.entities.UsuarioClinica;
import com.cibertec.denticore.security.services.AuthService;
import com.cibertec.denticore.security.services.ContextoClinicaService;
import com.cibertec.denticore.security.services.JwtService;
import com.cibertec.denticore.security.services.TokenBlackListService;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestHeader;
import jakarta.validation.Valid;

import java.net.URI;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final AuthService authService;
    private final TokenBlackListService tokenBlackListService;
    private final ContextoClinicaService contextoClinicaService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> login(@Valid @RequestBody LoginRequestDTO loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginRequest.getDni(),
                        loginRequest.getPassword()
                )
        );

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        UsuarioClinica membresia = contextoClinicaService
                .obtenerMembresiaPrincipal(userDetails.getUsuario().getId());

        String token = jwtService.generateToken(authentication);

        String rol = authentication.getAuthorities().stream()
                .findFirst()
                .map(GrantedAuthority::getAuthority)
                .map(authority -> authority.replace("ROLE_", ""))
                .orElse("DESCONOCIDO");

        return ResponseEntity.ok(new LoginResponseDTO(
                token,
                "Bearer",
                jwtService.getExpirationSeconds(),
                rol,
                contextoClinicaService.mapearContexto(membresia)));
    }

    @PostMapping("/registro/paciente")
    public ResponseEntity<RegistroPacienteResponseDTO> registrarPaciente(
            @Valid @RequestBody RegistroPacienteRequestDTO dto) {
        RegistroPacienteResponseDTO response = authService.registrarPaciente(dto);
        return ResponseEntity.created(URI.create("/api/v1/pacientes/me")).body(response);
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@RequestHeader("Authorization") String authorizationHeader) {
        String token = authorizationHeader.replace("Bearer ", "");
        tokenBlackListService.invalidarToken(token);
        return ResponseEntity.noContent().build();
    }

}
