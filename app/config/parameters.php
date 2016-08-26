<?php

include '/var/config/config.api.deepblu.php';

// Database
$this->container->setParameter('deepblu_database_host', $deepblu_database_host);
$this->container->setParameter('deepblu_database_port', $deepblu_database_port);
$this->container->setParameter('deepblu_database_name', $deepblu_database_name);
$this->container->setParameter('deepblu_database_user', $deepblu_database_user);
$this->container->setParameter('deepblu_database_password', $deepblu_database_password);

// Swiftmailer
$this->container->setParameter('mailer_transport', $mailer_transport);
$this->container->setParameter('mailer_host', $mailer_host);
$this->container->setParameter('mailer_user', $mailer_user);
$this->container->setParameter('mailer_password', $mailer_password);

// App Secret
$this->container->setParameter('secret', $secret);