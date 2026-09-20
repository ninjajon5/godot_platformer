using Godot;
using System;

namespace Game;

public partial class PhysicsReader: RefCounted 
{
	public bool onFloor;
	public Vector2 gravityVector;

	private void ReadPhysics(float gravity)
	{
		onFloor = IsOnFloor();
		gravityVector = new Vector2(0, gravity);
	}
}
