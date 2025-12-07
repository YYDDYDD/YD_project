using UnityEngine;
using UnityEngine.AI;

public class MoveToPickUpAndGoal : MonoBehaviour
{
    private NavMeshAgent agent;
    private GameObject currentTarget;
    private bool headingToGoal = false;

    void Start()
    {
        agent = GetComponent<NavMeshAgent>();

        currentTarget = GameObject.FindWithTag("PickUp");

        if(currentTarget != null)
        {
            agent.SetDestination(currentTarget.transform.position);
        }
        else
        {
            Debug.LogWarning("PickUpタグのオブジェクトが見つかりません！");
        }
    }

    void Update()
    {
        if(currentTarget == null)
            return;

        // destination への到達判定は remainingDistance を使う
        if(!agent.pathPending && agent.remainingDistance <= agent.stoppingDistance)
        {
            if(!headingToGoal)
            {
                GameObject goal = GameObject.FindWithTag("Goal");
                if(goal != null)
                {
                    currentTarget = goal;
                    agent.SetDestination(goal.transform.position);
                    headingToGoal = true;
                }
                else
                {
                    Debug.LogWarning("Goalタグのオブジェクトが見つかりません！");
                }
            }
        }
    }
}
