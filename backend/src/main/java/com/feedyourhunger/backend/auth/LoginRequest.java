package com.feedyourhunger.backend.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record LoginRequest(
        @NotBlank @Size(max = 254) String correo,
        @NotBlank @Size(max = 128) String contrasena) {
}
