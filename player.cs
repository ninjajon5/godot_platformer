using Godot;
using System;

namespace Player;

/*
 * TODO
 * convert files to cs
 * get tests passing
 * refactor animation
 * pause menu
 * debug in pause menu
*/

public partial class Player: CharacterBody2D {
    private const float _WalkingSpeed = 400.0f;
    private const float _RunningSpeed = 600.0f;
    private const float _Friction = 25.0f;
    private const float _Acceleration = 50.0f;
    private const float _Gravity = 30.0f;
    private const float _JumpVelocity = -600.0f;
    private const float _BackflipVelocity = 250.0f;
    private const int _FastFallingMultiplier = 4;
    private const int _DashingFrames = 15;
    private const int _JumpsquatFrames = 4;

    public InputReader inputs = new();

    public enum State
    {
        Resting,
        Walking,
        Running,
        RunTurnaround,
        Dashing,
        DashRelease,
        Jumpsquat,
        Jumping,
        Falling,
        FastFalling
    }
    private readonly State[] _GroundedInactionableStates = [ State.RunTurnaround, State.Jumpsquat ];
    public State state;
    public int dashingFrameCount = 0;
    public int jumpsquatFrameCount = 0;

    public bool onFloor;
    public bool fastFalling = false;
    public Vector2 gravityVector;

    public override void _PhysicsProcess(double delta)
    {
        inputs.ReadInputs();
    }


    private void ApplyGravity(int gravityMultiplier)
    {
        Vector2 velocity = Velocity;
        velocity += gravityVector * gravityMultiplier;
        Velocity = velocity;

        if ( GetNode<AnimatedSprite2D>("AnimatedSprite2D").Animation != "backflip" )
        {
            GetNode<AnimatedSprite2D>("AnimatedSprite2D").Play("jumping");
        }
    }



    private void ApplyFriction()
    {
        Velocity = new Vector2
        (
            Mathf.MoveToward( Velocity.X, 0, _Friction ),
            Velocity.Y
        );
    }


    private void Rest()
    {
        dashingFrameCount = 0;
        GetNode<AnimatedSprite2D>("AnimatedSprite2D").Play("resting");
    }


    private void Walk()
    {
        state = State.Walking;
        Velocity = new Vector2
        (
            Mathf.MoveToward( Velocity.X, _WalkingSpeed * inputs.axis, _Acceleration ),
            Velocity.Y
        );
        GetNode<AnimatedSprite2D>("AnimatedSprite2D").Play("walking");
        FlipAnimationBasedOnDirection();
    }



    private void Run()
    {
        state = State.Running;
        GetNode<AnimatedSprite2D>("AnimatedSprite2D").Play("walking");
        FlipAnimationBasedOnDirection();
    }


    private void RunTurnaround()
    {
        if ( state != State.RunTurnaround )
        {
            state = State.RunTurnaround;
            inputs.smashingStick = false;
            FlipAnimationBasedOnDirection();
        }
        ApplyFriction();
    }


    private void Dash()
    {
        state = State.Dashing;
        
        if ( InputOpposesDirection() ) dashingFrameCount = 0;

        Velocity = new Vector2( ( inputs.direction * _RunningSpeed ), Velocity.Y );
        dashingFrameCount += 1;

        GetNode<AnimatedSprite2D>("AnimatedSprite2D").Play("resting");
        FlipAnimationBasedOnDirection();
    }


    private void DashRelease()
    {
        state = State.DashRelease;
        dashingFrameCount = 0;
    }


    private void Jumpsquat()
    {
        state = State.Jumpsquat;
        jumpsquatFrameCount += 1;
        GetNode<AnimatedSprite2D>("AnimatedSprite2D").Play("jumpsquat");
    }


    private void Jump()
    {
        state = State.Jumping;
        fastFalling = false;
        jumpsquatFrameCount = 0;
        Velocity = new Vector2(Velocity.X, _JumpVelocity);
        if ( InputOpposesFacing() )
        {
            Velocity = new Vector2( (_BackflipVelocity * inputs.direction), Velocity.Y );
            GetNode<AnimatedSprite2D>("AnimatedSprite2D").Play("backflip");
        } 
        else if ( GetNode<AnimatedSprite2D>("AnimatedSprite2D").Animation != "backflip" )
        {
            GetNode<AnimatedSprite2D>("AnimatedSprite2D").Play("jumping");
        }
    }


    private void FlipAnimationBasedOnDirection()
    {
        GetNode<AnimatedSprite2D>("AnimatedSprite2D").FlipH = inputs.direction < 0 ;
    }

    
    private bool InputOpposesDirection()
    {
        return
        (
            Math.Sign(inputs.direction) != Math.Sign(Velocity.X)
            &&
            inputs.direction != 0
        );
    }


    private bool InputOpposesFacing()
    {
        return
        (
            ( inputs.direction > 0 && GetNode<AnimatedSprite2D>("AnimatedSprite2D").FlipH == true )
            || 
            ( inputs.direction < 0 && GetNode<AnimatedSprite2D>("AnimatedSprite2D").FlipH == false )
        );
    }
}
