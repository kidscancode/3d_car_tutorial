using Godot;

public class DemoCar : Car
{
    MeshInstance RightFrontWheel;
    MeshInstance LeftFrontWheel;

    public override void _Ready()
    {
        RightFrontWheel = GetNode<MeshInstance>("tmpParent/sedanSports/wheel_frontRight");
        LeftFrontWheel = GetNode<MeshInstance>("tmpParent/sedanSports/wheel_frontLeft");
    }

    public override void GetInput()
    {
        float turn = Input.GetActionStrength("steer_left");
        turn -= Input.GetActionStrength("steer_right");
        SteerAngle = turn * Mathf.Deg2Rad(SteeringLimit);
        // Rotate the wheels meshes - exaggerate for effect.
        RightFrontWheel.Rotation = new Vector3(
            RightFrontWheel.Rotation.x,
            SteerAngle * 2,
            RightFrontWheel.Rotation.z
        );
        LeftFrontWheel.Rotation = new Vector3(
            LeftFrontWheel.Rotation.x,
            SteerAngle * 2,
            LeftFrontWheel.Rotation.z
        );

        Acceleration = Vector3.Zero;
        if (Input.IsActionPressed("accelerate"))
        {
            Acceleration = -Transform.basis.z * EnginePower;
        }
        if (Input.IsActionPressed("brake"))
        {
            Acceleration = -Transform.basis.z * Breaking;
        }
    }
}
