package com.nexora.user.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.nexora.user.entity.AppUser;

public interface AppUserRepository extends JpaRepository<AppUser, Long> {

    Optional<AppUser> findByNormalizedEmail(String normalizedEmail);

    @Query("""
            select distinct user
            from AppUser user
            left join fetch user.roleAssignments assignment
            left join fetch assignment.role
            where user.id = :id
            """)
    Optional<AppUser> findByIdWithRoles(@Param("id") Long id);
}
