namespace BancoItens.Application.Dtos
{
    // Data Transfer Object (DTO) para a entrada de dados (Cadastro de Questão).
    public class QuestaoCadastroDto
    {
        public string Descricao { get; set; } = string.Empty;

        // 🛑 MUDANÇA CRÍTICA: A FK para a Disciplina agora é Guid.
        public Guid DisciplinaId { get; set; }
    }
}