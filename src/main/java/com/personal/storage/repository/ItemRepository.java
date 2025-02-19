package com.personal.storage.repository;

import com.personal.storage.entity.Item;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ItemRepository extends JpaRepository<Item, Long> {
    List<Item> findByStatus(String status);
    
    @Query("SELECT DISTINCT i FROM Item i JOIN i.tags t WHERE t = ?1")
    List<Item> findByTag(String tag);
    
    List<Item> findByNameContainingIgnoreCase(String name);
}
