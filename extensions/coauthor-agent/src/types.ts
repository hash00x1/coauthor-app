// types.ts - The contract that Agent-4 and Agent-5 must implement

import * as vscode from 'vscode';

/**
 * Configuration for the CoAuthor Agent.
 * Defines connection settings for the custom LLM webhook backend.
 */
export interface CoAuthorConfig {
    /** The URL endpoint for the LLM webhook */
    webhookUrl: string;
    /** API key for authentication with the webhook */
    apiKey: string;
    /** Optional model identifier to use for requests */
    modelId?: string;
    /** Optional maximum tokens for response generation */
    maxTokens?: number;
}

/**
 * Message format sent to the LLM backend.
 * Contains the user prompt, conversation history, and configuration.
 */
export interface LLMRequest {
    /** The current user prompt/message */
    prompt: string;
    /** Conversation history as an array of role/content pairs */
    history: Array<{ role: 'user' | 'assistant'; content: string }>;
    /** Partial configuration to override defaults */
    config: Partial<CoAuthorConfig>;
}

/**
 * The core function signature that Agent-5 must implement.
 * Invokes the LLM backend and streams the response to the chat UI.
 * 
 * @param request - The LLM request containing prompt, history, and config
 * @param stream - The VS Code chat response stream for outputting content
 * @param token - Cancellation token to abort the request
 * @returns Promise that resolves when streaming is complete
 */
export type LLMInvoker = (
    request: LLMRequest,
    stream: vscode.ChatResponseStream,
    token: vscode.CancellationToken
) => Promise<void>;
