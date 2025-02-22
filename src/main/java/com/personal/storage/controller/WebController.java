package com.personal.storage.controller;

import com.personal.storage.entity.Item;
import com.personal.storage.service.ItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.persistence.EntityNotFoundException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.stream.Collectors;

//@Controller
public class WebController {

    @Autowired
    private ItemService itemService;

    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("items", itemService.findAll());
        model.addAttribute("formItem", new Item());
        return "index";
    }

    @PostMapping("/item/save")
    public String saveItem(@ModelAttribute("formItem") Item item, @RequestParam(required = false) String tagString) {
        if (tagString != null && !tagString.trim().isEmpty()) {
            item.setTags(
                    Arrays.stream(tagString.split(","))
                            .map(String::trim)
                            .filter(tag -> !tag.isEmpty())
                            .collect(Collectors.toCollection(HashSet::new)));
        }
        itemService.saveItem(item);
        return "redirect:/";
    }

    @GetMapping("/item/delete/{id}")
    public String deleteItem(@PathVariable Long id) {
        itemService.deleteItem(id);
        return "redirect:/";
    }

    @GetMapping("/item/edit/{id}")
    public String editItem(@PathVariable Long id, Model model) {
        Item item = itemService.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Item not found with id: " + id));
        model.addAttribute("items", itemService.findAll());
        model.addAttribute("formItem", item);
        return "index";
    }
}
