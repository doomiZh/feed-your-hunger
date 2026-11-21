package com.feedyourhunger.backend.auth;

public class ShopDeactivatedException extends RuntimeException {

    public ShopDeactivatedException() {
        super("Comercio dado de baja");
    }
}
