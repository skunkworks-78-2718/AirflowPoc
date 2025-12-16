from airflow.providers.microsoft.azure.operators.container_instances import AzureContainerInstancesOperator
from azure.mgmt.containerinstance.models import ContainerGroupIdentity

class AzureContainerInstancesWithIdentityOperator(AzureContainerInstancesOperator):
    def __init__(self, *, identity: ContainerGroupIdentity = None, **kwargs):
        super().__init__(**kwargs)
        self.identity = identity

    def _create_container_group(self, *args, **kwargs):
        container_group = super()._create_container_group(*args, **kwargs)
        container_group.identity = self.identity
        return container_group
