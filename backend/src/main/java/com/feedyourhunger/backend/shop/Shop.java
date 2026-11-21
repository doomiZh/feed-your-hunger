package com.feedyourhunger.backend.shop;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "comercio")
public class Shop {

    @Id
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false)
    private ShopStatus status;

    protected Shop() {
    }

    public Long getId() {
        return id;
    }

    public ShopStatus getStatus() {
        return status;
    }
}
