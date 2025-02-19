package com.personal.storage.service.impl;

import com.personal.storage.entity.Item;
import com.personal.storage.repository.ItemRepository;
import com.personal.storage.service.ItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import javax.persistence.EntityNotFoundException;
import java.util.List;
import java.util.Optional;

@Service
public class ItemServiceImpl implements ItemService {

    @Autowired
    private ItemRepository itemRepository;

    @Override
    public Item saveItem(Item item) {
        return itemRepository.save(item);
    }

    @Override
    public Optional<Item> findById(Long id) {
        return itemRepository.findById(id);
    }

    @Override
    public List<Item> findAll() {
        return itemRepository.findAll();
    }

    @Override
    public List<Item> findByStatus(String status) {
        return itemRepository.findByStatus(status);
    }

    @Override
    public List<Item> findByTag(String tag) {
        return itemRepository.findByTag(tag);
    }

    @Override
    public List<Item> findByName(String name) {
        return itemRepository.findByNameContainingIgnoreCase(name);
    }

    @Override
    public void deleteItem(Long id) {
        itemRepository.deleteById(id);
    }

    @Override
    public Item updateItem(Long id, Item updatedItem) {
        return itemRepository.findById(id)
            .map(item -> {
                item.setName(updatedItem.getName());
                item.setDescription(updatedItem.getDescription());
                item.setStatus(updatedItem.getStatus());
                item.setPurchaseValue(updatedItem.getPurchaseValue());
                item.setPurchaseDate(updatedItem.getPurchaseDate());
                item.setTags(updatedItem.getTags());
                return itemRepository.save(item);
            })
            .orElseThrow(() -> new EntityNotFoundException("Item not found with id: " + id));
    }
}
