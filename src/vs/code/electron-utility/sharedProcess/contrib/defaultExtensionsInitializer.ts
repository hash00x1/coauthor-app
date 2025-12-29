/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { join } from '../../../../base/common/path.js';
import { Disposable } from '../../../../base/common/lifecycle.js';
import { URI } from '../../../../base/common/uri.js';
import { INativeEnvironmentService } from '../../../../platform/environment/common/environment.js';
import { INativeServerExtensionManagementService } from '../../../../platform/extensionManagement/node/extensionManagementService.js';
import { ILogService } from '../../../../platform/log/common/log.js';
import { IStorageService, StorageScope, StorageTarget } from '../../../../platform/storage/common/storage.js';
import { FileOperationResult, IFileService, IFileStat, toFileOperationResult } from '../../../../platform/files/common/files.js';
import { getErrorMessage } from '../../../../base/common/errors.js';

const defaultExtensionsInitStatusKey = 'initializing-default-extensions';

export class DefaultExtensionsInitializer extends Disposable {
	constructor(
		@INativeEnvironmentService private readonly environmentService: INativeEnvironmentService,
		@INativeServerExtensionManagementService private readonly extensionManagementService: INativeServerExtensionManagementService,
		@IStorageService storageService: IStorageService,
		@IFileService private readonly fileService: IFileService,
		@ILogService private readonly logService: ILogService,
	) {
		super();

		// CoAuthor: Debug logging
		console.log('[CoAuthor] DefaultExtensionsInitializer constructor called');
		this.logService.info('[CoAuthor] DefaultExtensionsInitializer constructor called');

		const currentKeyValue = storageService.getBoolean(defaultExtensionsInitStatusKey, StorageScope.APPLICATION, true);
		console.log(`[CoAuthor] Storage key '${defaultExtensionsInitStatusKey}' current value:`, currentKeyValue);
		this.logService.info(`[CoAuthor] Storage key '${defaultExtensionsInitStatusKey}' current value: ${currentKeyValue}`);

		console.log('[CoAuthor] appRoot:', this.environmentService.appRoot);
		this.logService.info('[CoAuthor] appRoot: ' + this.environmentService.appRoot);

		// CoAuthor: Always check for default extensions on first run (not just Windows)
		if (currentKeyValue) {
			console.log('[CoAuthor] Condition passed - will initialize default extensions');
			this.logService.info('[CoAuthor] Condition passed - will initialize default extensions');
			storageService.store(defaultExtensionsInitStatusKey, true, StorageScope.APPLICATION, StorageTarget.MACHINE);
			this.initializeDefaultExtensions().then(() => {
				console.log('[CoAuthor] Extension initialization complete, setting key to false');
				this.logService.info('[CoAuthor] Extension initialization complete, setting key to false');
				storageService.store(defaultExtensionsInitStatusKey, false, StorageScope.APPLICATION, StorageTarget.MACHINE);
			}).catch(error => {
				console.error('[CoAuthor] Error during extension initialization:', error);
				this.logService.error('[CoAuthor] Error during extension initialization', error);
			});
		} else {
			console.log('[CoAuthor] Condition failed - skipping default extensions (already initialized)');
			this.logService.info('[CoAuthor] Condition failed - skipping default extensions (already initialized)');
		}
	}

	private async initializeDefaultExtensions(): Promise<void> {
		const extensionsLocation = this.getDefaultExtensionVSIXsLocation();
		console.log('[CoAuthor] initializeDefaultExtensions called');
		console.log('[CoAuthor] Extensions location:', extensionsLocation.toString());
		this.logService.info('[CoAuthor] initializeDefaultExtensions called');
		this.logService.info('[CoAuthor] Extensions location: ' + extensionsLocation.toString());

		let stat: IFileStat;
		try {
			console.log('[CoAuthor] Attempting to resolve extensions directory...');
			stat = await this.fileService.resolve(extensionsLocation);
			console.log('[CoAuthor] Directory resolved successfully');
			console.log('[CoAuthor] stat.children:', stat.children);

			if (!stat.children) {
				console.log('[CoAuthor] No children found in directory');
				this.logService.debug('[CoAuthor] There are no default extensions to initialize', extensionsLocation.toString());
				return;
			}
		} catch (error) {
			console.error('[CoAuthor] Error resolving extensions directory:', error);
			if (toFileOperationResult(error) === FileOperationResult.FILE_NOT_FOUND) {
				console.log('[CoAuthor] Directory not found (FILE_NOT_FOUND)');
				this.logService.debug('[CoAuthor] There are no default extensions to initialize (directory not found)', extensionsLocation.toString());
				return;
			}
			this.logService.error('[CoAuthor] Error initializing extensions', error);
			return;
		}

		const vsixs = stat.children.filter(child => child.name.toLowerCase().endsWith('.vsix'));
		console.log(`[CoAuthor] Found ${vsixs.length} .vsix files`);
		vsixs.forEach(vsix => console.log(`[CoAuthor]   - ${vsix.name}`));

		if (vsixs.length === 0) {
			console.log('[CoAuthor] No .vsix files found');
			this.logService.debug('[CoAuthor] There are no default extensions to initialize (no .vsix files)', extensionsLocation.toString());
			return;
		}

		console.log('[CoAuthor] Starting installation of', vsixs.length, 'extension(s)');
		this.logService.info('[CoAuthor] Initializing default extensions', extensionsLocation.toString());
		await Promise.all(vsixs.map(async vsix => {
			console.log('[CoAuthor] Installing:', vsix.resource.toString());
			this.logService.info('[CoAuthor] Installing default extension', vsix.resource.toString());
			try {
				await this.extensionManagementService.install(vsix.resource, { donotIncludePackAndDependencies: true, keepExisting: false });
				console.log('[CoAuthor] ✓ Installed successfully:', vsix.name);
				this.logService.info('[CoAuthor] Default extension installed', vsix.resource.toString());
			} catch (error) {
				console.error('[CoAuthor] ✗ Installation failed:', vsix.name, error);
				this.logService.error('[CoAuthor] Error installing default extension', vsix.resource.toString(), getErrorMessage(error));
			}
		}));
		console.log('[CoAuthor] All extensions processed');
		this.logService.info('[CoAuthor] Default extensions initialized', extensionsLocation.toString());
	}

	private getDefaultExtensionVSIXsLocation(): URI {
		// appRoot = /path/to/CoAuthor.app/Contents/Resources/app
		// extensionsPath = /path/to/CoAuthor.app/Contents/Resources/app/extensions-vsix
		return URI.file(join(this.environmentService.appRoot, 'extensions-vsix'));
	}

}
