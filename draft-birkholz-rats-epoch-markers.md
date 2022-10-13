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
  RFC5652: CMS
  RFC8610: CDDL
  STD94:
    -: CBOR
    =: RFC8949
  STD96:
    -: COSE
    =: RFC9052

informative:
  I-D.ietf-rats-architecture: rats-arch
  I-D.ietf-rats-reference-interaction-models: rats-models
  I-D.birkholz-scitt-receipts: scitt-receipts

venue:
  mail: rats@ietf.org
  github: ietf-rats/draft-birkholz-rats-epoch-marker

--- abstract

This document defines Epoch Markers as a way to establish a notion of freshness among actors in a distributed system. Epoch Markers are similar to "time ticks" produced and distributed by a dedicated system, the Epoch Bell. Systems that receive Epoch Markers do not have to track freshness using their own understanding of time (e.g., via a local real-time clock). Instead, the reception of a certain Epoch Marker establishes a new epoch that is shared between all recipients.

--- middle

# Introduction

Systems that need to interact securely often require a shared understanding of the freshness of conveyed information. This is certainly the case in the domain of remote attestation procedures. In general, securely establishing a shared notion of freshness of the exchanged information among entities in a distributed system is not a simple task. The entire {{Appendix A of -rats-arch}} deals solely with the topic of freshness, which is in itself an indication of how relevant, and complex, it is to establish a trusted and shared understanding of freshness in a RATS system.

This document defines Epoch Markers as a way to establish a notion of freshness among actors in a distributed system. Epoch Markers are similar to "time ticks" produced and distributed by a dedicated system, the Epoch Bell. Systems that receive Epoch Markers do not have to track freshness using their own understanding of time (e.g., via a local real-time clock). Instead, the reception of a certain Epoch Marker establishes a new epoch that is shared between all recipients. In essence, the emissions and corresponding receptions of Epoch Markers are like the ticks of a clock where the ticks are conveyed by the Internet.  In general (barring highly symmetrical topologies), epoch ticking incurs differential latency due to the non-uniform distribution of receivers with respect to the Epoch Bell. This introduces skew that needs to be taken into consideration when Epoch Markers are used.

While all Epoch Markers share the same core property of behaving like clock ticks in a shared domain, various "epoch id" types are defined to accommodate different use cases and diverse kinds of Epoch Bells.

While Epoch Markers are encoded in CBOR {{-CBOR}}, and many of the epoch id types are themselves encoded in CBOR, a prominent format in this space is the Time-Stamp Token defined by {{-TSA}}, a DER-encoded TSTInfo value wrapped in a CMS envelope {{-CMS}}. Time-Stamp Tokens (TST) are produced by Time-Stamp Authorities (TSA) and exchanged via the Time-Stamp Protocol (TSP).

At the time of writing, TSAs are the most common providers of secure time-stamping services. Therefore, reusing the core TSTInfo structure as an epoch id type for Epoch Markers is instrumental for enabling smooth migration paths and promote interoperability. There are, however, several other ways to represent a signed timestamp, and therefore other inds of payloads that can be used to implement Epoch Markers.

To inform the design, this document discusses a number of interaction models in which Epoch Markers are expected to be exchanged.

The top-level structure of Epoch Markers alongside an initial set of epoch id types are specified using CDDL {{-CDDL}}. To increase trustworthiness in the Epoch Bell, Epoch Markers also provide the option to include a "veracity proof" in the form of attestation evidence, attestation results, or SCITT receipt {{-scitt-receipts}} associated with the trust status of the Epoch Bell.

## Requirements Notation

{::boilerplate bcp14-tagged}

In this document, CDDL {{-CDDL}} is used to describe the data formats.  The examples in {{examples}} use CBOR diagnostic notation defined in {{Section 8 of -CBOR}} and {{Appendix G of -CDDL}}.

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

Typically, a nonce is a number only used once. In the context of Epoch Markers, one Nonce can be distributed to multiple consumers, each of them using that Nonce only once. Technically, that is not a Nonce anymore. This type of Nonce is called Multi-Nonce in Epoch Markers.

~~~~ CDDL
{::include cddl/multi-nonce.cddl}
~~~~

### Multi-Nonce-List

A list of nonces send to multiple consumers. The consumers use each Nonce in the list of Nonces sequentially. Technically, each sequential Nonce in the distributed list is not used just once, but by every Epoch Marker consumer involved. This renders each Nonce in the list a Multi-Nonce

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

# Examples {#examples}

The example in {{fig-ex-1}} shows an epoch marker with a cbor-epoch-id and no
bell veracity proof.

~~~~ CBOR-DIAG
{::include cddl/examples/1.diag}
~~~~
{: #fig-ex-1 artwork-align="center"
   title="CBOR epoch id without bell veracity proof"}

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

