using Godot;

abstract public class Car : KinematicBody
{
    #region Car behaviour parameters, adjust as needed.
    [Export]
    public float Gravity = -20f;
    // Distance between front/rear axles
    [Export]
    public float WheelBase = .6f;
    // Front wheel max turning angle (deg)
    [Export]
    public float SteeringLimit = 10f;
    [Export]
    public float EnginePower = 6f;
    [Export]
    public float Breaking = -9f;
    [Export]
    public float Friction = -5f;
    [Export]
    public float Drag = -2f;
    [Export]
    public float MaxSpeedReverse = 3f;
    // Speed where traction is lost.
    [Export]
    public float SlipSpeed = 9f;
    // Traction when bellow SlipSpeed.
    [Export]
    public float TractionSlow = .75f;
    // Traction when drifting.
    [Export]
    public float TractionFast = .02f;
    #endregion

    #region Car state properties.
    protected Vector3 Acceleration = new Vector3(0f, 0f, 0f);
    protected Vector3 Velocity = new Vector3(0f, 0f, 0f);
    // Current wheel angle.
    protected float SteerAngle = 0f;
    protected bool Drifting = false;
    #endregion

    public override void _Process(float delta)
    {
        // If the car's in the air, you can't steer or accelerate.
        if (IsOnFloor())
        {
            GetInput();
            ApplyFriction(delta);
            CalculateSteering(delta);
        }

        Acceleration.y = Gravity;
        Velocity += Acceleration * delta;
        Velocity = MoveAndSlideWithSnap(Velocity, -Transform.basis.y, Vector3.Up, true);
    }

    public void ApplyFriction(float delta)
    {
        // Stop coasting if velocity is very low
        if (Velocity.Length() < .5f && Acceleration.Length() == 0)
        {
            Velocity.x = 0;
            Velocity.y = 0;
        }
        // Friction is proportional to velocity
        Vector3 frictionForce = Velocity * Friction * delta;
        // Drag is proportional to velocity squared.
        Vector3 dragForce = Velocity * Velocity.Length() * Drag * delta;
        Acceleration += dragForce + frictionForce;
    }

    public void CalculateSteering(float delta)
    {
        // Using bycycle model (one front/rear wheel)
        Vector3 rearWheel = Transform.origin + Transform.basis.z * WheelBase / 2f;
        Vector3 frontWheel = Transform.origin - Transform.basis.z * WheelBase / 2f;
        rearWheel += Velocity * delta;
        frontWheel += Velocity.Rotated(Transform.basis.y, SteerAngle) * delta;
        Vector3 newHeading = rearWheel.DirectionTo(frontWheel);

        // Traction
        if (!Drifting && Velocity.Length() > SlipSpeed)
        {
            Drifting = true;
        }
        if (Drifting && Velocity.Length() < SlipSpeed && SteerAngle == 0)
        {
            Drifting = false;
        }
        float traction = Drifting ? TractionFast : TractionSlow;

        // Are we going forward or reverse?
        float direction = newHeading.Dot(Velocity.Normalized());
        if (direction > 0)
        {
            Velocity = Learp(Velocity, newHeading * Velocity.Length(), traction);
        }
        if (direction < 0)
        {
            Velocity = -newHeading * Mathf.Min(Velocity.Length(), MaxSpeedReverse);
        }

        // Point in the steering direction.
        // NOTE: not necessarily the velocity direction.
        LookAt(Transform.origin + newHeading, Transform.basis.y);
    }

    // This is a simple implementation of Learp to Vector3
    // NOTE: Godot C# API doesn't implement Learp to Vectors
    protected Vector3 Learp(Vector3 from, Vector3 to, float by)
    {
        return new Vector3(
            Mathf.Lerp(from.x, to.x, by),
            Mathf.Lerp(from.y, to.y, by),
            Mathf.Lerp(from.z, to.z, by)
        );
    }

    // NOTE: This is a abstract method, and should be implemented in the real object
    abstract public void GetInput();
}
