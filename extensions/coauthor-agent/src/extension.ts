import * as vscode from 'vscode';
import { LLMRequest } from './types';
import { invokeLLM as invoker } from './agent';

export function activate(context: vscode.ExtensionContext): void {
    const handler: vscode.ChatRequestHandler = async (
        request: vscode.ChatRequest,
        chatContext: vscode.ChatContext,
        stream: vscode.ChatResponseStream,
        token: vscode.CancellationToken
    ): Promise<vscode.ChatResult> => {
        stream.progress('Thinking...');

        try {
            const history: Array<{ role: 'user' | 'assistant'; content: string }> = [];

            for (const turn of chatContext.history) {
                if (turn instanceof vscode.ChatRequestTurn) {
                    history.push({ role: 'user', content: turn.prompt });
                } else if (turn instanceof vscode.ChatResponseTurn) {
                    const parts: string[] = [];
                    for (const part of turn.response) {
                        if (part instanceof vscode.ChatResponseMarkdownPart) {
                            parts.push(part.value.value);
                        }
                    }
                    if (parts.length > 0) {
                        history.push({ role: 'assistant', content: parts.join('') });
                    }
                }
            }

            const llmRequest: LLMRequest = {
                prompt: request.prompt,
                history,
                config: {}
            };

            await invoker(llmRequest, stream, token);
        } catch (error) {
            const message = error instanceof Error ? error.message : 'An unexpected error occurred';
            stream.markdown(`**Error:** ${message}`);
        }

        return {};
    };

    const participant = vscode.chat.createChatParticipant('coauthor.agent', handler);

    const iconPath = vscode.Uri.joinPath(context.extensionUri, 'icon.png');
    participant.iconPath = iconPath;

    context.subscriptions.push(participant);
}

export function deactivate(): void {
    // No cleanup required
}
