.. Copyright (c) 2023 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
.. SPDX-License-Identifier: Apache-2.0

Deploy Traefik Ingress Controller
##################################

Objectives
**********
* Deploy & set up `Traefig ingress controller <https://github.com/traefik/traefik-helm-chart>`_.

Introduction
************
Traefik is a simple yet powerful reverse proxy that can be used as a `Kubernetes Ingress Controller <https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/>`_.
It can route traffic to a wide variety of infrastructure components and manages its configuration automatically.
The following steps install Traefik into your Kubernetes cluster.

Installation guide
******************

#. Add the Traefik Helm repository:

   .. code-block:: bash

      helm repo add traefik https://traefik.github.io/charts

#. Confirm Helm chart availability

After the previous step we should be able to search the repo for the Traefik chart:

.. code-block:: bash

     helm search repo traefik

Expected output:

.. code-block:: console

     NAME                    CHART VERSION   APP VERSION     DESCRIPTION                                       
     traefik/traefik         23.2.0          v2.10.4         A Traefik based Kubernetes ingress controller     
     traefik/traefik-hub     1.0.6           v2.1.0          Traefik Hub Ingress Controller                    
     traefik/traefik-mesh    4.1.1           v1.4.8          Traefik Mesh - Simpler Service Mesh               
     traefik/traefikee       1.14.1          v2.10.2         Traefik Enterprise is a unified cloud-native ne...
     traefik/hub-agent       1.6.0           v1.4.2          Traefik Hub is an all-in-one global networking ...
     traefik/maesh           2.1.2           v1.3.2          Maesh - Simpler Service Mesh

#. Install Traefik:

   The following command expects that you are in the root directory your clone of the `accompanying resources <https://github.com/DACH-NY/daml-enterprise-deployment-blueprints/>`_.

   .. code-block:: bash

      helm -n traefik install traefik traefik/traefik --set disableValidation=true -f src/helm/values/traefik.yaml --create-namespace

Expected output:

.. code-block:: console

     NAME: traefik
     LAST DEPLOYED: Wed Aug  2 11:08:59 2023
     NAMESPACE: traefik
     STATUS: deployed
     REVISION: 1
     TEST SUITE: None
     NOTES:
     Traefik Proxy v2.10.4 has been deployed successfully on traefik namespace !

Let us verify the traefik pod's availability:

.. code-block:: bash

     kubectl -n traefik get pods

Expected output:

.. code-block:: console

     NAME                      READY   STATUS    RESTARTS   AGE
     traefik-894c9975c-z6mst   1/1     Running   0          15m
