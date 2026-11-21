USE dnaqms;

INSERT INTO DisplayTemplate (OrganizationId, TemplateName, TemplateType, LayoutConfigJson, IsDefault, IsActive, CreatedBy, ModifiedBy)
VALUES 
(1, 'Waiting Room 4K Grid View', 1, '{"columns":3,"rows":2,"theme":"dark"}', 1, 1, 1, 1),
(1, 'Split-Screen Educational Video & Queue', 2, '{"videoUrl":"https://example.com/stream","splitRatio":"60/40"}', 0, 1, 1, 1),
(1, 'High-Density Rapid Dispatch Board', 3, '{"itemsPerPage":12,"fontSize":"large"}', 0, 1, 1, 1);
