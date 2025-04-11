---
v: 3

title: Epoch Markers
abbrev: Epoch Markers
docname: draft-ietf-rats-epoch-markers-latest
stand_alone: true
area: Security
wg: RATS Working Group
kw: Internet-Draft

venue:
  mail: rats@ietf.org
  github: ietf-rats/draft-birkholz-rats-epoch-marker

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
  RFC5652: CMS
  RFC8392: CWT
  RFC8610: CDDL
  RFC9090: CBOR-OID
  RFC9054: COSE-HASH-ALGS
  STD94: CBOR
#    =: RFC8949
  STD96: COSE
#    =: RFC9052
  RFC9581: CBOR-ETIME
  I-D.ietf-cose-cbor-encoded-cert: C509
  I-D.ietf-cbor-edn-literals: EDN
  X.690:
    title: >
      Information technology — ASN.1 encoding rules:
      Specification of Basic Encoding Rules (BER), Canonical Encoding
      Rules (CER) and Distinguished Encoding Rules (DER)
    author:
      org: International Telecommunications Union
    date: 2015-08
    seriesinfo:
      ITU-T: Recommendation X.690
    target: https://www.itu.int/rec/T-REC-X.690

informative:
  RFC9334: rats-arch
  I-D.ietf-rats-reference-interaction-models: rats-models
  I-D.ietf-scitt-architecture: scitt-receipts
  I-D.ietf-rats-eat: rats-eat
  I-D.ietf-lamps-csr-attestation: csr-attestation
  TCG-CoEvidence:
    author:
      org: Trusted Computing Group
    title: "TCG DICE Concise Evidence Binding for SPDM"
    target: https://trustedcomputinggroup.org/wp-content/uploads/TCG-DICE-Concise-Evidence-Binding-for-SPDM-Version-1.0-Revision-53_1August2023.pdf
    date: 2023-06
    rc: Version 1.00
  I-D.ietf-rats-ar4si: rats-ar4si
  IANA.cwt:
  IANA.cbor-tags:

entity:
  SELF: "RFCthis"

--- abstract

This document defines Epoch Markers as a means to establish a notion of freshness among actors in a distributed system.
Epoch Markers are similar to "time ticks" and are produced and distributed by a dedicated system known as the Epoch Bell.
Systems receiving Epoch Markers do not need to track freshness using their own understanding of time (e.g., via a local real-time clock).
Instead, the reception of a specific Epoch Marker establishes a new epoch that is shared among all recipients.
This document defines Epoch Marker types, including CBOR time tags, RFC 3161 TimeStampToken, nonce-like structures, and a CWT Claim to embed Epoch Markers in RFC 8392 CBOR Web Tokens, which serve as vehicles for signed protocol messages.

--- middle

# Introduction

Systems that need to interact securely often require a shared understanding of the freshness of conveyed information.
This is certainly the case in the domain of remote attestation procedures.
In general, securely establishing a shared notion of freshness of the exchanged information among entities in a distributed system is not a simple task.

The entire {{Appendix A of -rats-arch}} deals solely with the topic of freshness, which is in itself an indication of how relevant, and complex, it is to establish a trusted and shared understanding of freshness in a RATS system.

This document defines Epoch Markers as a way to establish a notion of freshness among actors in distributed systems.
Epoch Markers are similar to "time ticks" and are produced and distributed by a dedicated system, the Epoch Bell.
Actors in a system that receive Epoch Markers do not have to track freshness using their own understanding of time (e.g., via a local real-time clock).
Instead, the reception of a certain Epoch Marker establishes a new epoch that is shared between all recipients.
In essence, the emissions and corresponding receptions of Epoch Markers are like the ticks of a clock, with these ticks being conveyed over the Internet.

In general (barring highly symmetrical topologies), epoch ticking incurs differential latency due to the non-uniform distribution of receivers with respect to the Epoch Bell.
This introduces skew that needs to be taken into consideration when Epoch Markers are used.

While all Epoch Markers share the same core property of behaving like clock ticks in a shared domain, various "Epoch ID" values are defined as Epoch Marker types in this document to accommodate different use cases and diverse kinds of Epoch Bells.

While most Epoch Markers types are encoded in CBOR {{-CBOR}}, and many of the Epoch ID types are themselves encoded in CBOR, a prominent format in this space is the TimeStampToken (TST) defined by {{-TSA}}, a DER-encoded TSTInfo value wrapped in a CMS envelope {{-CMS}}.
TSTs are produced by Time-Stamp Authorities (TSA) and exchanged via the Time-Stamp Protocol (TSP).
At the time of writing, TSAs are the most common providers of secure time-stamping services.
Therefore, reusing the core TSTInfo structure as an Epoch ID type for Epoch Markers is instrumental for enabling smooth migration paths and promote interoperability.
There are, however, several other ways to represent a signed timestamp or the start of a new freshness epoch, respectively, and therefore other Epoch Marker types.

To inform the design, this document discusses a number of interaction models in which Epoch Markers are expected to be exchanged.
The default top-level structure of Epoch Markers described in this document is CBOR Web Tokens {{-CWT}}.
An extensible set of Epoch Marker types, along with the `em` CWT claim to include them in CWTs, is specified using CDDL {{-CDDL}}.
CWTs are signed using COSE {{-COSE}} and benefit from wide tool support.
However, CWTs are not the only containers in which Epoch Markers can be embedded.
Epoch Markers can be included in any type of message that allows for the embedding of opaque bytes or CBOR data items.
Examples include the Collection CMW in {{-csr-attestation}}, Evidence formats such as {{TCG-CoEvidence}} or {{-rats-eat}}, {{-rats-ar4si}}, or the CWT Claims Header Parameter of {{-scitt-receipts}}.

## Requirements Notation

{::boilerplate bcp14-tagged}

In this document, CDDL {{-CDDL}} is used to describe the data formats.  The examples in {{examples}} use the CBOR Extended Diagnostic Notation (EDN, {{-EDN}}).

# Epoch IDs

The RATS architecture introduces the concept of Epoch IDs that mark certain events during remote attestation procedures ranging from simple handshakes to rather complex interactions including elaborate freshness proofs.
The Epoch Markers defined in this document are a solution that includes the lessons learned from TSAs, the concept of Epoch IDs defined in the RATS architecture, and provides several means to identify a new freshness epoch. Some of these methods are introduced and discussed in Section 10.3 of the RATS architecture {{-rats-arch}}.

# Interaction Models {#interaction-models}

The interaction models illustrated in this section are derived from the RATS Reference Interaction Models {{-rats-models}}.
In general, there are three major interaction models used in remote attestation:

* ad-hoc requests (e.g., via challenge-response requests addressed at Epoch Bells), corresponding to {{Section 7.1 of -rats-models}}
* unsolicited distribution (e.g., via uni-directional methods, such as broad- or multicasting from Epoch Bells), corresponding to {{Section 7.2 of -rats-models}}
* solicited distribution (e.g., via a subscription to Epoch Bells), corresponding to {{Section 7.3 of -rats-models}}

In all three interaction models, Epoch Markers can be used as content for the generic information element `handle` as introduced by {{-rats-models}}.
Handles are used to establish freshness in ad-hoc, unsolicited, and solicited distribution mechanisms of an Epoch Bell.
For example, an Epoch Marker can be used as a nonce in challenge-response remote attestation (e.g., for limiting the number of ad-hoc requests by a Verifier).
If embedded in a CWT, an Epoch Marker can be used as a `handle` by extracting the value of the `em` Claim or by using the complete CWT including an `em` Claim (e.g., functioning as a signed time-stamp token).
Using an Epoch Marker requires the challenger to acquire an Epoch Marker beforehand, which may introduce a sensible overhead compared to using a simple nonce.

# Epoch Marker Structure {#sec-epoch-markers}

Epoch Markers are tagged CBOR data items.
As a default, Epoch Markers are transported via the `em` Claim in CWTs.
In cases of challenge-response interactions that employ a nonce to show recentness, the `em` Claim can be paired with a `Nonce` Claim to bind the nonce with the Epoch Marker as a response message in an ad-hoc request.
This in fact means that it is possible to request an Epoch Marker via a challenge-response interaction using a nonce to than use the received CWT or the Epoch Marker included as a different nonce in a separate RATS reference interaction model.

~~~~ cddl
{::include cddl/epoch-marker.cddl}
~~~~
{: #fig-epoch-marker-cddl artwork-align="left"
   title="Epoch Marker types"}

~~~~ cddl
{::include cddl/epoch-marker-claim.cddl}
~~~~
{: #fig-epoch-marker-cwt artwork-align="left"
   title="Epoch Marker as a CWT Claim"}

## Epoch Marker Types {#epoch-payloads}

This memo comes with a set of predefined Epoch Marker types.

### CBOR Time Tags

A CBOR time representation choosing from CBOR tag 0 (`tdate`, RFC3339 time as a string), tag 1 (`time`, Posix time as int or float) or tag 1001 (extended time data item).

See {{Section 3 of -CBOR-ETIME}} for the (many) details about the CBOR extended time format (tag 1001).
See {{Sections 3.4.1 and 3.4.2 of RFC8949@-CBOR}} for `tdate` (tag 0) and `time` (tag 1).

~~~~ cddl
{::include cddl/cbor-time-tag.cddl}
~~~~

The following describes cbor-time type choice.

etime:

: A freshly sourced timestamp represented as either `time` or `tdate`
  ({{Sections 3.4.2 and 3.4.1 of RFC8949@-CBOR}}, {{Appendix D of -CDDL}}) or `etime` {{-CBOR-ETIME}}.

nonce:

: An optional random byte string used as extra data in challenge-response interaction models (see {{-rats-models}}).


#### Creation

To generate the cbor-time value, the emitter MUST follow the requirements in {{sec-time-reqs}}.

If a nonce is generated, the emitter MUST follow the requirements in {{sec-nonce-reqs}}.


### Classical RFC 3161 TST Info {#sec-rfc3161-classic}

DER-encoded {{X.690}} TSTInfo {{-TSA}}.  See {{classic-tstinfo}} for the layout.

~~~~ cddl
{::include cddl/classical-rfc3161-tst-info.cddl}
~~~~

The following describes the classical-rfc3161-TST-info type.

classical-rfc3161-TST-info:

: The DER-encoded TSTInfo generated by a {{-TSA}} Time Stamping Authority.

#### Creation

The Epoch Bell MUST use the following value as MessageImprint in its request to the TSA:

~~~ asn.1
SEQUENCE {
  SEQUENCE {
    OBJECT      2.16.840.1.101.3.4.2.1 (sha256)
    NULL
  }
  OCTET STRING
    BF4EE9143EF2329B1B778974AAD445064940B9CAE373C9E35A7B23361282698F
}
~~~

This is the sha-256 hash of the string "EPOCH_BELL".

The TimeStampToken obtained by the TSA MUST be stripped of the TSA signature.
Only the TSTInfo is to be kept the rest MUST be discarded.
The Epoch Bell COSE signature will replace the TSA signature.

### CBOR-encoded RFC3161 TST Info {#sec-rfc3161-fancy}

[^issue] https://github.com/ietf-rats/draft-birkholz-rats-epoch-marker/issues/18

[^issue]: Issue tracked at:

The TST-info-based-on-CBOR-time-tag is semantically equivalent to classical {{-TSA}} TSTInfo, rewritten using the CBOR type system.

~~~~ cddl
{::include cddl/tst-info.cddl}
~~~~

The following describes each member of the TST-info-based-on-CBOR-time-tag map.

{:vspace}
version:
: The integer value 1.  Cf. version, {{Section 2.4.2 of -TSA}}.

policy:
: A {{-CBOR-OID}} object identifier tag (111 or 112) representing the TSA's policy under which the tst-info was produced.
Cf. policy, {{Section 2.4.2 of -TSA}}.

messageImprint:
: A {{-COSE-HASH-ALGS}} COSE_Hash_Find array carrying the hash algorithm
identifier and the hash value of the time-stamped datum.
Cf. messageImprint, {{Section 2.4.2 of -TSA}}.

serialNumber:
: A unique integer value assigned by the TSA to each issued tst-info.
Cf. serialNumber, {{Section 2.4.2 of -TSA}}.

eTime:
: The time at which the tst-info has been created by the TSA.
Cf. genTime, {{Section 2.4.2 of -TSA}}.
Encoded as extended time {{-CBOR-ETIME}}, indicated by CBOR tag 1001, profiled as follows:

- The "base time" is encoded using key 1, indicating Posix time as int or float.
- The stated "accuracy" is encoded using key -8, which indicates the maximum
  allowed deviation from the value indicated by "base time". The duration map
  is profiled to disallow string keys. This is an optional field.
- The map MAY also contain one or more integer keys, which may encode
  supplementary information [^tf1].

[^tf1]: Allowing unsigned integer (i.e., critical) keys goes counter interoperability

{:vspace}
ordering:
: boolean indicating whether tst-info issued by the TSA can be ordered solely based on the "base time".
This is an optional field, whose default value is "false".
Cf. ordering, {{Section 2.4.2 of -TSA}}.

nonce:
: int value echoing the nonce supplied by the requestor.
Cf. nonce, {{Section 2.4.2 of -TSA}}.

tsa:
: a single-entry GeneralNames array {{Section 11.8 of -C509}} providing a hint in identifying the name of the TSA.
Cf. tsa, {{Section 2.4.2 of -TSA}}.

$$TSTInfoExtensions:
: A CDDL socket ({{Section 3.9 of -CDDL}}) to allow extensibility of the data format.
Note that any extensions appearing here MUST match an extension in the
corresponding request.
Cf. extensions, {{Section 2.4.2 of -TSA}}.

#### Creation

The Epoch Bell MUST use the following value as messageImprint in its request to the TSA:

~~~ cbor-diag
[
    / hashAlg   / -16, / sha-256 /
    / hashValue / h'BF4EE9143EF2329B1B778974AAD44506
                    4940B9CAE373C9E35A7B23361282698F'
]
~~~

This is the sha-256 hash of the string "EPOCH_BELL".

### Epoch Tick {#sec-epoch-tick}

An Epoch Tick is a single opaque blob sent to multiple consumers.

~~~~ cddl
{::include cddl/multi-nonce.cddl}
~~~~

The following describes the epoch-tick type.

epoch-tick:

: Either a string, a byte string, or an integer used by RATS roles within a trust domain as extra data (`handle`) included in conceptual messages {{-rats-arch}} to associate them with a certain epoch, similar to a nonce.
Technically, an Epoch Tick is not used just once (like a nonce), but by every Epoch Marker consumer involved.

#### Creation

The emitter MUST follow the requirements in {{sec-nonce-reqs}}.

### Epoch Tick List {#sec-epoch-tick-list}

A list of Epoch Ticks send to multiple consumers.
The consumers use each Epoch Tick in the list of sequentially, similar to a list of nonces.
Technically, each sequential Epoch Tick in the distributed list is not used just once (like a nonce), but by every Epoch Marker consumer involved.

~~~~ cddl
{::include cddl/multi-nonce-list.cddl}
~~~~

The following describes the Epoch Tick List type.

epoch-tick-list:

: A sequence of byte strings used by RATS roles in trust domain as extra data (`handle`) in the generation of conceptual messages as specified by the RATS architecture {{-rats-arch}} to associate them with a certain epoch.
Each Epoch Tick in the list is used in a consecutive generation of a conceptual message.
Asserting freshness of a conceptual message including an Epoch Tick from the epoch-tick-list requires some state on the receiver side to assess if that Epoch Tick is the appropriate next unused Epoch Tick from the epoch-tick-list.

#### Creation

The emitter MUST follow the requirements in {{sec-nonce-reqs}}.

### Strictly Monotonically Increasing Counter {#sec-strictly-monotonic}

A strictly monotonically increasing counter.

The counter context is defined by the Epoch bell.

~~~~ cddl
{::include cddl/strictly-monotonic-counter.cddl}
~~~~

The following describes the strictly-monotonic-counter type.

strictly-monotonic-counter:

: An unsigned integer used by RATS roles in a trust domain as extra data in the production of conceptual messages as specified by the RATS architecture {{-rats-arch}} to associate them with a certain epoch. Each new strictly-monotonic-counter value must be higher than the last one.

## Time Requirements {#sec-time-reqs}

Time MUST be sourced from a trusted clock.

## Nonce Requirements {#sec-nonce-reqs}

A nonce value used in a protocol or message to retrieve an Epoch Marker MUST be freshly generated.
The generated value MUST have at least 64 bits of entropy (before encoding).
The generated value MUST be generated via a cryptographically secure random number generator.

A maximum nonce size of 512 bits is set to limit the memory requirements.
All receivers MUST be able to accommodate the maximum size.

# Security Considerations

TODO

# IANA Considerations {#sec-iana-cons}

[^rfced-replace]

[^rfced-replace]: RFC Editor: please replace {{&SELF}} with the RFC
    number of this RFC and remove this note.

## New CBOR Tags {#sec-iana-cbor-tags}

IANA is requested to allocate the following tags in the "CBOR Tags" registry
{{IANA.cbor-tags}}, preferably with the specific CBOR tag value requested:

| Tag | Data Item | Semantics | Reference |
| -- | -- | -- | -- |
| 26980 | bytes | DER-encoded RFC3161 TSTInfo | {{sec-rfc3161-classic}} of {{&SELF}} |
| 26981 | map | CBOR-encoding of RFC3161 TSTInfo semantics | {{sec-rfc3161-fancy}} of {{&SELF}} |
| 26982 | tstr / bstr / int | a nonce that is shared among many participants but that can only be used once by each participant | {{sec-epoch-tick}} of {{&SELF}} |
| 26983 | array | a list of multi-nonce | {{sec-epoch-tick-list}} of {{&SELF}} |
| 26984 | uint | strictly monotonically increasing counter | {{sec-strictly-monotonic}} of {{&SELF}} |
{: #tbl-cbor-tags align="left" title="New CBOR Tags"}

## New EM CWT Claim {#sec-iana-em-claim}

This specification adds the following value to the "CBOR Web Token Claims" registry {{IANA.cwt}}.

* Claim Name: em
* Claim Description: Epoch Marker
* Claim Key: 2000 (IANA: suggested assignment)
* Claim Value Type(s): CBOR array
* Change Controller: IETF
* Specification Document(s): {{sec-epoch-markers}} of {{&SELF}}

--- back

# Examples {#examples}

The example in {{fig-ex-1}} shows an Epoch Marker with an `etime` as the Epoch Marker type.

~~~~ cbor-diag
{::include cddl/examples/1.diag}
~~~~
{: #fig-ex-1 artwork-align="center"
   title="CBOR Epoch Marker based on `etime` (EDN)"}

The encoded data item in CBOR pretty-printed form (hex with comments) is shown in {{fig-ex-1-pretty}}.

~~~~ cbor-pretty
{::include cddl/examples/1.pretty}
~~~~
{: #fig-ex-1-pretty artwork-align="center"
   title="CBOR Epoch Marker based on `etime` (pretty hex)"}


## RFC 3161 TSTInfo {#classic-tstinfo}

As a reference for the definition of TST-info-based-on-CBOR-time-tag the code block below depicts the original layout of the TSTInfo structure from {{-TSA}}.

~~~~ asn.1
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
