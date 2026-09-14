using Godot;

namespace Game;

public partial class Debug : Label
{
    private Player _player;
    private float _maxInputAxis = -1.0f;
    private string _state;
    private string[] _recentStates = { "-", "-", "-", "-", "-" };

    public override void _Ready()
    {
        _player = GetNode<Player>("../../Player");
    }

    public override void _Process(double delta)
    {
        if ( _player.inputs.axis > _maxInputAxis ) _maxInputAxis = _player.inputs.axis;

        _state = _player.state.ToString();
        UpdateRecentStates(_state);

        Text = $@"state: {_state}
        recentStates: [ {_recentStates[0]}, {_recentStates[1]}, {_recentStates[2]}, {_recentStates[3]}, {_recentStates[4]}, {_recentStates[5]} ]
        dashingFrameCount: {_player.dashingFrameCount}
        jumpsquatFrameCount: {_player.jumpsquatFrameCount}
        smashingStick: {_player.inputs.smashingStick}
        smashStickLeftFrameCount: {_player.inputs.smashStickLeftFrameCount}
        smashStickRightFrameCount: {_player.inputs.smashStickRightFrameCount}
        inputDirection: {_player.inputs.direction}
        inputAxis: {_player.inputs.axis}
        maxInputDirection: {_maxInputAxis}
        speed: {_player.Velocity.X}";
    }

    private void UpdateRecentStates(string newState)
    {
        int endIndex = System.Array.IndexOf(_recentStates, newState);
        if ( endIndex == -1 ) endIndex = _recentStates.Length - 1;

        for ( int i = endIndex; i > 0; i-- )
        {
            _recentStates[i] = _recentStates[i - 1];
        }

        _recentStates[0] = newState;
    }
}
