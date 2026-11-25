package com.feedyourhunger.backend.account;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "usuario")
public class UserAccount {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "correo", nullable = false)
    private String email;

    @Column(name = "contrasena_hash", nullable = false)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(name = "rol", nullable = false)
    private Role role;

    @Column(name = "intentos_fallidos", nullable = false)
    private short failedAttempts;

    @Column(name = "tiempo_bloqueo")
    private Instant lockedUntil;

    protected UserAccount() {
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public Role getRole() {
        return role;
    }

    public short getFailedAttempts() {
        return failedAttempts;
    }

    public Instant getLockedUntil() {
        return lockedUntil;
    }
}
