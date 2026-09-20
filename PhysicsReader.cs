using Godot;

namespace Game;

public partial class PhysicsReader: RefCounted 
{
	public bool onFloor;
	public Vector2 gravityVector;

	public void ReadPhysics(float gravity)
	{
		onFloor = IsOnFloor();
		gravityVector = new Vector2(0, gravity);
	}
}
