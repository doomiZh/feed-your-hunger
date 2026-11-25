package com.feedyourhunger.backend.account;

import java.time.Instant;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

public interface UserAccountRepository extends JpaRepository<UserAccount, Long> {
    Optional<UserAccount> findByEmail(String email);

    @Transactional
    @Modifying
    @Query(value = """
            UPDATE usuario
            SET intentos_fallidos = intentos_fallidos + 1,
                tiempo_bloqueo = CASE
                    WHEN intentos_fallidos + 1 >= :maxAttempts THEN :lockedUntil
                    ELSE tiempo_bloqueo
                END
            WHERE correo = :email
            """, nativeQuery = true)
    int registerFailedAttempt(@Param("email") String email,
                              @Param("maxAttempts") int maxAttempts,
                              @Param("lockedUntil") Instant lockedUntil);

    @Transactional
    @Modifying
    @Query(value = """
            UPDATE usuario
            SET intentos_fallidos = 0,
                tiempo_bloqueo = NULL
            WHERE correo = :email
            """, nativeQuery = true)
    int resetFailedAttempts(@Param("email") String email);
}
