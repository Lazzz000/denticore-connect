package com.cibertec.denticore.security.services;

import com.cibertec.denticore.security.dto.request.RegistroPacienteRequestDTO;
import com.cibertec.denticore.security.dto.response.RegistroPacienteResponseDTO;

public interface AuthService {

    RegistroPacienteResponseDTO registrarPaciente(RegistroPacienteRequestDTO dto);
}
