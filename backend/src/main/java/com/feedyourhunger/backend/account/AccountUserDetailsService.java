package com.feedyourhunger.backend.account;

import java.util.Locale;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class AccountUserDetailsService implements UserDetailsService {

    private final UserAccountRepository repository;

    public AccountUserDetailsService(UserAccountRepository repository) {
        this.repository = repository;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        String normalizedEmail = email.trim().toLowerCase(Locale.ROOT);
        UserAccount account = repository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new UsernameNotFoundException("Cuenta no encontrada"));
        return User.withUsername(account.getEmail())
                .password(account.getPasswordHash())
                .authorities("ROLE_" + account.getRole().name())
                .build();
    }
}
