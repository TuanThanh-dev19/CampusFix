package com.nexora.ticket.workflow;

/** Distinguishes ticket creation from transitions applied to a persisted ticket. */
public enum TicketTransitionSource {
    NEW_REQUEST,
    EXISTING_TICKET
}
