using Godot;
using System;
using System.Linq;

namespace Game;

/*
 * TODO
 * set up PlayerState to hold all non-Godot stuff
 * make extractor function to pull Godot stuff back out (e.g. Velocity)
 * refactor animation (should be a PlayerState attribute that's extracted)
 * make PlayerState factory to set defaults that tests can re-use
 * extract PlayerLogic into stateless class with PlayerState as only input
 * set up xUnit demo test
 * get tests passing using xUnit
 * pause menu
 * debug in pause menu
*/

public partial class Player: CharacterBody2D {

	// constants
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

	// inputs
	public InputReader inputs = new();
    public PhysicsReader physics = new();

	// state tracking
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
	public bool fastFalling = false;

	public override void _PhysicsProcess(double delta)
	{
		inputs.ReadInputs();
		ReadPhysics();

		CheckForPhysicsTransitions();
		ApplyInputsDependingOnState();

		MoveAndSlide();
	}

	public void ReadPhysics()
	{
		physics.onFloor = IsOnFloor();
		physics.gravityVector = new Vector2(0, _Gravity);
	}

	private void CheckForPhysicsTransitions()
	{
		if( !physics.onFloor && Velocity.Y >= 0 && state != State.FastFalling )
		{
			state = State.Falling;
		}
		else if ( physics.onFloor && Velocity.X == 0 && state != State.Jumpsquat )
		{
			state = State.Resting;
		}
		else if ( physics.onFloor && ( state == State.Falling | state == State.FastFalling ) )
		{
			state = State.Walking;
		}
	}


	private void ApplyInputsDependingOnState()
	{
		ResetInputsIfInactionable();
		switch(state)
		{
			case State.Resting: 
				ApplyInputsToRestingState();
				break;
			case State.Walking:
				ApplyInputsToWalkingState();
				break;
			case State.Running:
				ApplyInputsToRunningState();
				break;
			case State.RunTurnaround:
				ApplyInputsToRunTurnaroundState();
				break;
			case State.Dashing:
				ApplyInputsToDashingState();
				break;
			case State.DashRelease:
				ApplyInputsToDashReleaseState();
				break;
			case State.Jumpsquat:
				ApplyInputsToJumpsquatState();
				break;
			case State.Jumping:
				ApplyInputsToJumpingState();
				break;
			case State.Falling:
				ApplyInputsToFallingState();
				break;
			case State.FastFalling:
				ApplyInputsToFastFallingState();
				break;
		}
	}



	private void ResetInputsIfInactionable()
	{
		if ( _GroundedInactionableStates.Contains(state) && inputs.smashingStick ) inputs.ResetSmashingStick();
	}


	private void ApplyInputsToRestingState()
	{
		if ( inputs.direction != 0 )
		{
			if ( inputs.smashingStick )
			{
				Dash();
			}
			else
			{
				Walk();
			}
		}
		else
		{
			Rest();
		}

		if ( inputs.jump ) Jumpsquat();
	}


	private void ApplyInputsToWalkingState()
	{
		if ( inputs.smashingStick )
		{
			Dash();
		}
		else
		{
			Walk();
		}

		if ( inputs.jump ) Jumpsquat();
	}


	private void ApplyInputsToRunningState()
	{
		if ( inputs.direction != 0 )
		{
			if ( InputOpposesDirection() )
			{
				RunTurnaround();
			}
			else
			{
				Run();
			}
		}
		else
		{
			ApplyFriction();
		}

		if ( inputs.jump ) Jumpsquat();
	}


	private void ApplyInputsToRunTurnaroundState()
	{
		RunTurnaround();
		if ( inputs.jump ) Jumpsquat();
	}


	private void ApplyInputsToDashingState()
	{
		if ( inputs.direction != 0 && inputs.smashingStick )
		{
			if ( dashingFrameCount <= _DashingFrames )
			{
				Dash();
			}
			else
			{
				Run();
			}
		}
		else
		{
			DashRelease();
			ApplyFriction();
		}

		if ( inputs.jump ) Jumpsquat();
	}


	private void ApplyInputsToDashReleaseState()
	{
		if ( inputs.direction != 0 && InputOpposesDirection() && inputs.smashingStick )
		{
			Dash();
		}
		else
		{
			ApplyFriction();
		}

		if ( inputs.jump ) Jumpsquat();
	}


	private void ApplyInputsToJumpsquatState()
	{
		if ( jumpsquatFrameCount >= _JumpsquatFrames )
		{
			Jump();
		}
		else
		{
			Jumpsquat();
		}
	}


	private void ApplyInputsToJumpingState()
	{
		ApplyGravity(1);
	}


	private void ApplyInputsToFallingState()
	{
		if( inputs.crouch )
		{
			state = State.FastFalling;
			ApplyGravity(_FastFallingMultiplier);
		}
		else
		{
			ApplyGravity(1);
		}

		if ( GetNode<AnimatedSprite2D>("AnimatedSprite2D").Animation != "backflip" )
		{
			GetNode<AnimatedSprite2D>("AnimatedSprite2D").Play("jumping");
		}
	}


	private void ApplyInputsToFastFallingState()
	{
		ApplyGravity(_FastFallingMultiplier);
	}


	private void ApplyGravity(int gravityMultiplier)
	{
		Vector2 velocity = Velocity;
		velocity += physics.gravityVector * gravityMultiplier;
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
