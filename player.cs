using Godot;
using System;

public partial class Player: CharacterBody2D {
    private float _walkingSpeed = 400.0f;
    private float _runningSpeed = 600.0f;
    private float _friction = 25.0f;
    private float _acceleration = 50.0f;
    private float _gravity = 30.0f;
    private float _jumpVelocity = -600.0f;
    private float _backflipVelocity = 250.0f;
    private int _fastFallingMultiplier = 4;
    private int _dashingFrames = 15;
    private int _jumpsquatFrames = 4;
}
