package com.personal.storage.service;

import com.personal.storage.entity.Item;
import java.util.List;
import java.util.Optional;

public interface ItemService {
    Item saveItem(Item item);
    Optional<Item> findById(Long id);
    List<Item> findAll();
    List<Item> findByStatus(String status);
    List<Item> findByTag(String tag);
    List<Item> findByName(String name);
    void deleteItem(Long id);
    Item updateItem(Long id, Item item);
}
