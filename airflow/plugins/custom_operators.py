from airflow.providers.microsoft.azure.operators.container_instances import AzureContainerInstancesOperator
from azure.mgmt.containerinstance.models import ContainerGroupIdentity

class AzureContainerInstancesWithIdentityOperator(AzureContainerInstancesOperator):
    def __init__(self, *, identity: ContainerGroupIdentity = None, **kwargs):
        super().__init__(**kwargs)
        self.identity = identity

    def execute(self, context):
        from airflow.providers.microsoft.azure.hooks.container_instance import AzureContainerInstanceHook
        
        # Store original method
        original_create_or_update = AzureContainerInstanceHook.create_or_update
        identity = self.identity
        
        # Patch to inject identity
        def patched_create_or_update(self_hook, resource_group, name, container_group):
            if identity:
                container_group.identity = identity
            return original_create_or_update(self_hook, resource_group, name, container_group)
        
        # Apply patch
        AzureContainerInstanceHook.create_or_update = patched_create_or_update
        
        try:
            return super().execute(context)
        finally:
            # Restore original
            AzureContainerInstanceHook.create_or_update = original_create_or_update
