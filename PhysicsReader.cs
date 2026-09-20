using Godot;
using System;

namespace Game;

public partial class PhysicsReader: RefCounted 
{
	public bool onFloor;
	public Vector2 gravityVector;

	private void ReadPhysics()
	{
		onFloor = IsOnFloor();
		gravityVector = new Vector2(0, _Gravity);
	}
}
