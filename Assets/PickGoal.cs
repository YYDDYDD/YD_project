using UnityEngine;
using UnityEngine.AI;

public class PickGoal: MonoBehaviour

{
    [Header("References")]
    [Tooltip("The target to move toward after touching a PickUp.")]
    public Transform goal;

    [Header("Settings")]
    [Tooltip("Tag used to identify PickUp objects.")]
    public string pickUpTag = "PickUp";

    [Tooltip("Speed used if no NavMeshAgent is present.")]
    public float fallbackSpeed = 3.5f;

    [Tooltip("Minimum distance to consider 'arrived' at the goal.")]
    public float arriveDistance = 0.25f;

    private NavMeshAgent agent;
    private bool shouldMove;
    private bool arrived;

    void Awake()
    {
        agent = GetComponent<NavMeshAgent>();
        if(agent != null)
        {
            // Make sure the agent doesn't auto-update position if you control transform elsewhere
            agent.autoBraking = true;
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if(arrived || shouldMove)
            return; // already moving or done
        if(other.CompareTag(pickUpTag))
        {
            if(goal == null)
            {
                Debug.LogWarning($"{name}: Goal not assigned.");
                return;
            }

            shouldMove = true;

            // Use NavMesh if available
            if(agent != null && agent.isOnNavMesh)
            {
                agent.isStopped = false;
                agent.SetDestination(goal.position);
            }
        }
    }

    void Update()
    {
        if(!shouldMove || arrived || goal == null)
            return;

        if(agent != null && agent.isOnNavMesh)
        {
            // Check arrival via agent
            if(!agent.pathPending && agent.remainingDistance <= arriveDistance)
            {
                arrived = true;
                agent.isStopped = true;
            }
        }
        else
        {
            // Fallback: simple transform-based movement
            Vector3 toGoal = goal.position - transform.position;
            float distance = toGoal.magnitude;

            if(distance <= arriveDistance)
            {
                arrived = true;
                return;
            }

            Vector3 step = toGoal.normalized * fallbackSpeed * Time.deltaTime;
            transform.position += step;

            // Optional: face goal
            if(step.sqrMagnitude > 0.0001f)
            {
                transform.rotation = Quaternion.Slerp(
                    transform.rotation,
                    Quaternion.LookRotation(toGoal, Vector3.up),
                    10f * Time.deltaTime
                );
            }
        }
    }

    // Optional gizmo for clarity
    void OnDrawGizmosSelected()
    {
        if(goal == null)
            return;
        Gizmos.color = Color.green;
        Gizmos.DrawLine(transform.position, goal.position);
        Gizmos.DrawWireSphere(goal.position, arriveDistance);
    }
}
