---
v: 3

title: Epoch Markers
abbrev: Epoch Markers
docname: draft-birkholz-rats-epoch-markers-latest
stand_alone: true
area: Security
wg: RATS Working Group
kw: Internet-Draft

cat: std
consensus: true
submissiontype: IETF

author:
- name: Henk Birkholz
  org: Fraunhofer SIT
  abbrev: Fraunhofer SIT
  email: henk.birkholz@sit.fraunhofer.de
  street: Rheinstrasse 75
  code: '64295'
  city: Darmstadt
  country: Germany
- name: Thomas Fossati
  organization: Arm Limited
  email: Thomas.Fossati@arm.com
  country: UK
- name: Wei Pan
  org: Huawei Technologies
  email: william.panwei@huawei.com
- name: Carsten Bormann
  org: Universität Bremen TZI
  street: Bibliothekstr. 1
  city: Bremen
  code: D-28359
  country: Germany
  phone: +49-421-218-63921
  email: cabo@tzi.org

normative:
  RFC3161: TSA

informative:
  I-D.ietf-rats-architecture: rats-arch
  I-D.ietf-rats-reference-interaction-models: rats-models

venue:
  mail: rats@ietf.org
  github: ietf-rats/draft-birkholz-rats-epoch-marker

--- abstract

Abstract Text

--- middle

# Introduction

Systems that are required to interact via secure interactions often require a shared understanding of the freshness of conveyed information, especially in the domain of remote attestation procedures.
Establishing a notion of freshness between various involved entities taking on roles that rely on information that is not outdated is not simple.
In general, establishing a shared understanding of freshness in a secure manner is not simple.
The RATS architecture {{-rats-arch}} dedicates an extensive appendix solely on the topic of freshness considerations and that fact alone should be considered a telltale sign on how necessary yet complex establishing a trusted and shared understanding of freshness between systems actually is.

This document provides a prominent way to establish a notion of freshness between systems: Epoch Markers.
Epoch Markers are messages that are like time ticks produced and conveyed by a system in a freshness domain: the Epoch Bell.
Systems that receive Epoch Markers do not have to track freshness with their own local understanding of time (e.g., a local real time clock).
Instead, each reception of a specific Epoch Marker rings in a new age of freshness that is shared between all recipients.
In essence, the emissions and corresponding receptions of Epoch Markers are like the ticks of a clock where the ticks are conveyed by the Internet.

The layout of the freshness domain in which Epoch Markers are conveyed like the ticks of a clock, introduces a domain-specific latency -- and therefore a certain uncertainty about tick accuracy.

While all Epoch Markers share the common characteristic of being like clock ticks in a freshness domain, there are various payload types that can make up the content of an Epoch Marker.
These different types of Epoch Marker payloads address several specific use cases and are laid out in this document.
While Epoch Markers are encoded in CBOR and many of the payload types are encoded in CBOR as well, a prominent payload is the Time Stamp Token content as defined by {{RFC3161}}: a DER-encoded TSTInfo value.
Time Stamp Tokens (TST) produced by Time Stamp Authorities (TSA) are conveyed by the Time Stamp Protocol (TSP).
At the time of writing,
TSAs are the most common world-wide implemented secure timestamp token systems.
Reusing the essential TST payload structure as a payload type for CBOR encoded Epoch Markers makes sense with respect to migration paths and general interoperability.
But there is more than one way to represent a signed timestamp and other kinds of freshness ticks that can be used for Epoch Markers.

In this document, basic interaction models on how to convey Epoch Marchers are illustrated as they impact the message design of a generic Epoch Marker.
Then, the structure of Epoch Markers is specified using CDDL and the corresponding payload types are introduced and elaborated on.
To increase the level of trustworthiness in the Epoch Bell and the
system that produces them,
Epoch Markers also provide the option to include (concise) remote attestation evidence or corresponding remote attestation results.

## Requirements Notation

{::boilerplate bcp14-tagged}

# Epoch IDs

The RATS architecture introduces the concept of Epoch IDs that mark certain events during remote attestation procedures ranging from simple handshakes to rather complex interactions including elaborate freshness proofs.
The Epoch Markers defined in this document are a solution that includes the lessons learned from TSAs, the concept of Epoch IDs and provides several means to identify a new freshness epoch. Some of these methods are introduced and discussed in Section 10.3 by the RATS architecture {{-rats-arch}}.

# Interaction Models {#interaction-models}

The interaction models illustrated in this section are derived from the RATS Reference Interaction Models.
In general there are three of them:

* ad-hoc requests (e.g., via challenge-response requests addressed at Epoch Bells), corresponding to Section 7.1 in {{-rats-models}}
* unsolicited distribution (e.g., via uni-directional methods, such as broad- or multicasting from Epoch Bells), corresponding to Section 7.2 in {{-rats-models}}
* solicited distribution (e.g., via a subscription to Epoch Bells), corresponding to Section 7.3 in {{-rats-models}}

# Epoch Marker

At the top level, an Epoch Marker is a CBOR array with a header carrying a protocol/interaction-specific message ({{interaction-models}}), and a payload

~~~~ CDDL
{::include cddl/epoch-marker.cddl}
~~~~
{: #fig-epoch-marker-cddl artwork-align="left"
   title="Epoch Marker definition"}

## Epoch Marker Payloads

This memo comes with a set of predefined payloads.

### CBOR Time Tag (etime)

Thomas: a versatile CBOR time representation, potentially bundled with a Nonce

~~~~ CDDL
{::include cddl/cbor-time-tag.cddl}
~~~~

### Classical RFC 3161 TST Info

Thomas: DER-encoded value of TSTInfo

~~~~ CDDL
{::include cddl/classical-rfc3161-tst-info.cddl}
~~~~

### CBOR-encoded RFC3161 TST Info

Thomas tells us here what beautiful things we concocted here with CBOR magic

~~~~ CDDL
{::include cddl/tst-info.cddl}
~~~~

### Multi-Nonce

Thomas (FIXME): Typically, a nonce is a number only used once. In the context of Epoch Markers, one Nonce can be distributed to multiple consumers, each of them using that Nonce only once. Technically, that is not a Nonce anymore. This type of Nonce is called Multi-Nonce in Epoch Markers.

~~~~ CDDL
{::include cddl/multi-nonce.cddl}
~~~~

### Multi-Nonce-List

Thomes: A list of nonces send to multiple consumers. The consumers use each Nonce in the list of Nonces sequentially. Technically, each sequential Nonce in the distributed list is not used just once, but by every Epoch Marker consumer involved. This renders each Nonce in the list a Multi-Nonce

~~~~ CDDL
{::include cddl/multi-nonce-list.cddl}
~~~~

### Strictly Monotonically Increasing Counter

Thomas beautiful context fable

; Strictly Monotonically Increasing Counter
; counter++
; counter context? per issuer? per indicator?

~~~~ CDDL
{::include cddl/multi-nonce-list.cddl}
~~~~

# Security Considerations

TODO

# IANA Considerations

TODO

--- back

# Examples

TODO

~~~~ CBOR-DIAG
{::include cddl/examples/1.diag}
~~~~

## RFC 3161 TSTInfo

As a reference for the definition of TST-info-based-on-CBOR-time-tag the code block below depects the original layout of the TSTInfo structure from {{-TSA}}.

~~~~ ASN.1
TSTInfo ::= SEQUENCE  {
   version                      INTEGER  { v1(1) },
   policy                       TSAPolicyId,
   messageImprint               MessageImprint,
     -- MUST have the same value as the similar field in
     -- TimeStampReq
   serialNumber                 INTEGER,
    -- Time-Stamping users MUST be ready to accommodate integers
    -- up to 160 bits.
   genTime                      GeneralizedTime,
   accuracy                     Accuracy                 OPTIONAL,
   ordering                     BOOLEAN             DEFAULT FALSE,
   nonce                        INTEGER                  OPTIONAL,
     -- MUST be present if the similar field was present
     -- in TimeStampReq.  In that case it MUST have the same value.
   tsa                          [0] GeneralName          OPTIONAL,
   extensions                   [1] IMPLICIT Extensions   OPTIONAL  }
~~~~

# Acknowledgements
{:unnumbered}

TBD

