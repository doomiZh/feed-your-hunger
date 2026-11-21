package com.feedyourhunger.backend.auth;

import com.feedyourhunger.backend.account.Role;
import com.feedyourhunger.backend.account.UserAccount;
import com.feedyourhunger.backend.account.UserAccountRepository;
import com.feedyourhunger.backend.shop.Shop;
import com.feedyourhunger.backend.shop.ShopRepository;
import com.feedyourhunger.backend.shop.ShopStatus;
import java.util.Locale;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserAccountRepository accounts;
    private final ShopRepository shops;

    public AuthService(AuthenticationManager authenticationManager,
                       UserAccountRepository accounts,
                       ShopRepository shops) {
        this.authenticationManager = authenticationManager;
        this.accounts = accounts;
        this.shops = shops;
    }

    public Authentication login(String email, String password) {
        Authentication authentication = authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken.unauthenticated(
                        email.trim().toLowerCase(Locale.ROOT), password));
        UserAccount account = findAccount(authentication.getName());
        if (account.getRole() == Role.COMERCIO && shopStatusOf(account) == ShopStatus.BAJA) {
            throw new ShopDeactivatedException();
        }
        return authentication;
    }

    public SessionResponse describe(Authentication authentication, int maxInactiveSeconds) {
        UserAccount account = findAccount(authentication.getName());
        ShopStatus shopStatus = account.getRole() == Role.COMERCIO ? shopStatusOf(account) : null;
        return new SessionResponse(account.getEmail(), account.getRole(), shopStatus, maxInactiveSeconds);
    }

    private UserAccount findAccount(String email) {
        return accounts.findByEmail(email)
                .orElseThrow(() -> new BadCredentialsException("Cuenta no encontrada"));
    }

    private ShopStatus shopStatusOf(UserAccount account) {
        return shops.findById(account.getId())
                .map(Shop::getStatus)
                .orElseThrow(() -> new IllegalStateException("El comercio no tiene fila en la tabla comercio"));
    }
}
