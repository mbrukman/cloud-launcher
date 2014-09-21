from gce import *

def RabbitMQ_Node(
    name, role, sourceImage, startupScript, machineType='n1-standard-2'):
  return Compute.instance(
    name=name,
    machineType=machineType,
    disks=[
      Disk.boot(
        autoDelete=true,
        initializeParams=Disk.initializeParams(
          sourceImage=sourceImage,
        ),
      ),
    ],
    metadata=Metadata.create(
      items=[
        Metadata.startupScript(startupScript),
        Metadata.item('rabbitmq-role', role),
      ],
    ),
  )

def RabbitMQ_Cluster(
    sourceImage, startupScript,
    numRamNodes=4, ramNodeMachineType='n1-standard-2',
    numDiscNodes=3, discNodeMachineType='n1-standard-2'):
  ram_nodes = [
      RabbitMQ_Node(
        name='rabbitmq-ram-%d' % i,
        role='ram',
        sourceImage=sourceImage,
        startupScript=startupScript,
      ) for i in range(0, numRamNodes)]

  disc_nodes = [
      RabbitMQ_Node(
        name='rabbitmq-disc-%d' % i,
        role='disc',
        sourceImage=sourceImage,
        startupScript=startupScript,
      ) for i in range(0, numDiscNodes)]

  resources = ram_nodes + disc_nodes

  # Collect all node names.
  all_nodes = []
  for resource in resources:
    all_nodes.append(resource.name)

  # Point each of the nodes towards all the others for discovery.
  for resource in resources:
    other_nodes = [node for node in all_nodes if node != resource.name]
    # Note: we can't use the syntax "resource.metadata.items.append" because
    # our dict-like object has the method "items()" which will shadow the field.
    resource.metadata['items'].append(
        Metadata.item('rabbitmq-servers', ' '.join(other_nodes)))

  return resources
