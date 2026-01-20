import * as vscode from 'vscode';
import type { LLMRequest, LLMInvoker } from './types';

// Node.js 18+ globals available in VS Code extension host
declare function fetch(input: string, init?: RequestInit): Promise<Response>;
declare class AbortController {
    readonly signal: AbortSignal;
    abort(reason?: unknown): void;
}
declare class TextDecoder {
    constructor(label?: string);
    decode(input?: Uint8Array, options?: { stream?: boolean }): string;
}
interface RequestInit {
    method?: string;
    headers?: Record<string, string>;
    body?: string;
    signal?: AbortSignal;
}
interface Response {
    ok: boolean;
    status: number;
    statusText: string;
    body: ReadableStream<Uint8Array> | null;
}
interface ReadableStream<R> {
    getReader(): ReadableStreamDefaultReader<R>;
}
interface ReadableStreamDefaultReader<R> {
    read(): Promise<ReadableStreamReadResult<R>>;
    cancel(reason?: unknown): Promise<void>;
}
type ReadableStreamReadResult<T> = { done: false; value: T } | { done: true; value?: undefined };
interface AbortSignal {
    readonly aborted: boolean;
}

/**
 * Invokes the LLM webhook backend and streams the response to the chat UI.
 */
export const invokeLLM: LLMInvoker = async (
    request: LLMRequest,
    stream: vscode.ChatResponseStream,
    token: vscode.CancellationToken
): Promise<void> => {
    const config = vscode.workspace.getConfiguration('coauthor.agent');
    const webhookUrl = config.get<string>('webhookUrl');
    const apiKey = config.get<string>('apiKey') ?? '';

    if (!webhookUrl) {
        throw new Error('CoAuthor Agent: webhookUrl is not configured. Set it in Settings > CoAuthor Agent.');
    }

    const controller = new AbortController();
    const cancellationListener = token.onCancellationRequested(() => {
        controller.abort();
    });

    try {
        const response = await fetch(webhookUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`
            },
            body: JSON.stringify(request),
            signal: controller.signal
        });

        if (!response.ok) {
            const statusText = response.statusText || 'Unknown error';
            throw new Error(`Webhook request failed: ${response.status} ${statusText}`);
        }

        if (!response.body) {
            throw new Error('Webhook response has no body');
        }

        const reader = response.body.getReader();
        const decoder = new TextDecoder('utf-8');

        while (true) {
            if (token.isCancellationRequested) {
                reader.cancel();
                break;
            }

            const { done, value } = await reader.read();

            if (done) {
                break;
            }

            const chunk = decoder.decode(value, { stream: true });
            if (chunk) {
                stream.markdown(chunk);
            }
        }
    } catch (error) {
        if (error instanceof Error && error.name === 'AbortError') {
            return;
        }
        throw error;
    } finally {
        cancellationListener.dispose();
    }
};
