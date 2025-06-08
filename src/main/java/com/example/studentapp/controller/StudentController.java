package com.example.studentapp.controller;

import com.example.studentapp.model.Student;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
public class StudentController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @PostMapping("/students")
    public String addStudent(@ModelAttribute Student student) {
        String sql = "INSERT INTO students (name, age) VALUES (?, ?)";
        jdbcTemplate.update(sql, student.getName(), student.getAge());
        return "redirect:/index.html"; // redirect back to form
    }
}

