﻿using UnityEngine;

public class CrosshairAnimator : MonoBehaviour
{
    [SerializeField] private InteractionSystem interactionSystem;
    [SerializeField] private Transform crosshair;
    [SerializeField] private Vector3 interactableScale;
    [SerializeField] private Vector3 normalScale;
    [SerializeField] private float animationSpeed;
    
    private void Update()
    {
        Vector3 target = interactionSystem.LookingAtInteractable ? interactableScale : normalScale;
        crosshair.localScale = Vector3.MoveTowards(crosshair.localScale, target, animationSpeed * Time.deltaTime);
    }
}