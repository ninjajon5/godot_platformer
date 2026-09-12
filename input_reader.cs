using Godot;
using System;

public partial class InputReader: RefCounted 
{
    private const int _SmashStickFrames = 4;
    private const float _SmashStickAxis = 0.75f;

    public bool jump = false;
    public bool crouch = false;
    public bool left = false;
    public bool right = false;
    public float axis = 0.0f;
    public int direction = 0;
    public int smashStickLeftFrameCount = 0;
    public int smashStickRightFrameCount = 0;
    public bool smashingStick = false;

    public void ReadInputs()
    {
        jump = Input.IsActionJustPressed("jump");
        crouch = Input.IsActionJustPressed("crouch");
        left = Input.IsActionJustPressed("left");
        right = Input.IsActionJustPressed("right");
        axis = Input.GetAxis("left", "right");
        direction = Math.Sign(axis);
        CheckForSmashStick();
}

    public void ResetSmashingStick()
    {
        smashingStick = false;

        if ( direction == -1 )
        {
            smashStickRightFrameCount = _SmashStickFrames + 1;
        }
        else if ( direction == 1 )
        {
            smashStickRightFrameCount = _SmashStickFrames + 1;
        }
    }

    private void CheckForSmashStick()
    {
        if ( axis >= _SmashStickAxis )
        {
            if ( smashStickRightFrameCount <= _SmashStickFrames ) smashingStick = true;
        }
        else if ( axis <= _SmashStickAxis )
        {
            if ( smashStickLeftFrameCount <= _SmashStickFrames ) smashingStick = true;
        }
        else
        {
            smashingStick = false;
            UpdateSmashStickFrameCounts();
        }
    }

    private void UpdateSmashStickFrameCounts()
    {
        if ( direction > 0.0 )
        {
            smashStickLeftFrameCount = 0;
            smashStickRightFrameCount += 1;
        }
        else if ( direction < 0.0 )
        {
            smashStickLeftFrameCount += 1;
            smashStickRightFrameCount = 0;
        }
        else
        {
            smashStickLeftFrameCount = 0;
            smashStickRightFrameCount = 0;
        }
    }
}
