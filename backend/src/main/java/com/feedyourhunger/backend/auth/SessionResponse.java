package com.feedyourhunger.backend.auth;

import com.feedyourhunger.backend.account.Role;
import com.feedyourhunger.backend.shop.ShopStatus;

public record SessionResponse(
        String correo,
        Role rol,
        ShopStatus estadoComercio,
        int inactividadMaxSegundos) {
}
